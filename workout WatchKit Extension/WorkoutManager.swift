//
//  WorkoutManager.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 10.06.21.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    var outdoor: Bool = false
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else {
                return
            }
            startWorkout(workoutType: selectedWorkout)
        }
    }
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        if workoutType == .swimming {
            configuration.swimmingLocationType = outdoor ? .openWater : .pool
            if outdoor == false {
                configuration.lapLength = HKQuantity.init(unit: HKUnit.meter(), doubleValue: 25)
            }
        } else {
            configuration.locationType = outdoor ? .outdoor : .indoor
        }
        
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print(error)
            //Handle exceptions
            return
        }
        
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session?.delegate = self
        builder?.delegate = self
        
        //Start
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { success, error in
            //started
        }
    }
    
    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) {
            (success, error) in
            //Handle error
        }
    }
    
    // MARK: - State Control
    
    @Published var running = false
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }
    
    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }
    
    @Published var averageHearRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var walkingSteadiness: Double = 0
    @Published var excerciseTimeSeconds: Double = 0
    @Published var workout: HKWorkout?
    
    func updateForStatistics(_ statitstics: HKStatistics?) {
        guard let statitstics = statitstics else {
            return
        }
        
        DispatchQueue.main.async {
            switch statitstics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statitstics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHearRate = statitstics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statitstics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
                HKQuantityType.quantityType(forIdentifier: .distanceSwimming):
                let meterUnit = HKUnit.meter()
                self.distance = statitstics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness):
                let percentage = HKUnit.percent()
                self.walkingSteadiness = statitstics.sumQuantity()?.doubleValue(for: percentage) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .appleExerciseTime):
                let timeUnit = HKUnit.second()
                self.excerciseTimeSeconds = statitstics.sumQuantity()?.doubleValue(for: timeUnit) ?? 0
            default:
                return
            }
        }
    }
    
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        averageHearRate = 0
        heartRate = 0
        activeEnergy = 0
        distance = 0
        walkingSteadiness = 0
        excerciseTimeSeconds = 0
    }
}


// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        
        
        // waiting for session to transition states before ending trhe builder
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, eror) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
                
            }
        }
    }
}

// MARK: - HKWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            updateForStatistics(statistics)
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
}

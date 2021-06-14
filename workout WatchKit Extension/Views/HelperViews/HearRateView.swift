//
//  HearRateView.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 11.06.21.
//

import SwiftUI

struct HearRateView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    private let heartRate = HearRate()
    
    var body: some View {
        Text(
            workoutManager.heartRate
                .formatted(
                    .number.precision(.fractionLength(0))
                )
            + " bpm"
        ).foregroundColor(colorForHearRate(heartRate: workoutManager.heartRate))
        
    }
    
    func colorForHearRate(heartRate: Double) -> Color {
        if heartRate < HearRate.L1HeartRate {
            HearRate.L1HeartRateTime+=1
            HearRate.fitnessZone = .belowFitnessZone
            return .gray
        }
        if heartRate < HearRate.L2HeartRate {
            HearRate.L2HeartRateTime+=1
            HearRate.fitnessZone = .fitnessZone
            return .white
        }
        if heartRate < HearRate.L3HeartRate {
            HearRate.L3HeartRateTime+=1
            HearRate.fitnessZone = .aboveFitnessZone
            return .blue
        }
        if heartRate < HearRate.L4HeartRate {
            HearRate.L4HeartRateTime+=1
            HearRate.fitnessZone = .fitnessZone
            return .green
        }
        if heartRate < HearRate.L5HeartRate {
            HearRate.L5HeartRateTime+=1
            HearRate.fitnessZone = .fitnessZone
            return .yellow
        }
        if heartRate < HearRate.maximumHeartRate {
            HearRate.maximumHeartRateTime+=1
            HearRate.fitnessZone = .aboveFitnessZone
            return .orange
        }
        HearRate.aboveMaximumHeartRateTime+=1
        HearRate.fitnessZone = .aboveFitnessZone
        return .red
    }
}

enum HeartRateMode {
    case belowFitnessZone
    case fitnessZone
    case aboveFitnessZone
}

struct HearRate {
    //https://www.polar.com/blog/running-heart-rate-zones-basics/
    static let age: Double = 39
    static var maximumHeartRate: Double {return 220 - age}
    static var L5HeartRate: Double {return maximumHeartRate * 0.9}
    static var L4HeartRate: Double {return maximumHeartRate * 0.8}
    static var L3HeartRate: Double {return maximumHeartRate * 0.7}
    static var L2HeartRate: Double {return maximumHeartRate * 0.6}
    static var L1HeartRate: Double {return maximumHeartRate * 0.5}
    
    private static var privateFitnessZone: HeartRateMode = .belowFitnessZone
    static var fitnessZone : HeartRateMode {
        get { return privateFitnessZone}
        set(newValue) {
            if newValue == .belowFitnessZone || newValue == .aboveFitnessZone {
                if privateFitnessZone == .fitnessZone {
                    WKInterfaceDevice.current().play(.failure)
                }
            }
            privateFitnessZone = newValue
        }
    }
    
    //in healthkit update frame seconds
    static var L5HeartRateTime: Int = 0
    static var L4HeartRateTime: Int = 0
    static var L3HeartRateTime: Int = 0
    static var L2HeartRateTime: Int = 0
    static var L1HeartRateTime: Int = 0
    static var maximumHeartRateTime: Int = 0
    static var aboveMaximumHeartRateTime: Int = 0
}

struct HearRateView_Previews: PreviewProvider {
    static var previews: some View {
        HearRateView()
    }
}

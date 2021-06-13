//
//  ContentView.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 10.06.21.
//

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var workoutTypes0: [HKWorkoutActivityType] = [
            .running,
            .swimming]
    var workoutTypes1: [HKWorkoutActivityType] = [
            .walking]
    
    var body: some View {
        VStack {
            HStack{
                Toggle("🌦", isOn: $workoutManager.outdoor)
            }
            HStack{
                List(workoutTypes0) { workoutType in
                    NavigationLink( //?
                        workoutType.name,
                        destination: SessionPaginView(),
                        tag: workoutType,
                        selection: $workoutManager.selectedWorkout
                    )
                        .padding(
                            EdgeInsets(top: 15, leading: 5,
                                       bottom: 15, trailing: 5)
                        )
                }
                List(workoutTypes1) { workoutType in
                    NavigationLink( //?
                        workoutType.name,
                        destination: SessionPaginView(),
                        tag: workoutType,
                        selection: $workoutManager.selectedWorkout
                    )
                        .padding(
                            EdgeInsets(top: 15, leading: 5,
                                       bottom: 15, trailing: 5)
                        )
                    
                }
            }
            .navigationBarTitle("Workouts")
            .onAppear {
                workoutManager.requestAuthorization()
            }
        }.scenePadding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(WorkoutManager())
    }
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String {
        switch self {
        case .running:
            return "🏃‍♂️"
        case .swimming:
            return "🏊🏻‍♂️"
        case .walking:
            return "🚶🏽‍♀️🐶"
        default:
            return ""
        }
    }
}

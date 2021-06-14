//
//  MetricsView.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 10.06.21.
//

import SwiftUI
import HealthKit

struct MetricsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var isAnimating = false
    private var repeatingAnimation: Animation {
        Animation.easeInOut(duration: 0.4)
            .repeatForever()
    }
    
    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(
                from: workoutManager.builder?.startDate ?? Date()
            )
        ) { context in
            
            VStack(alignment: .leading) {
                ElapsedTimeView(
                    elapsedTime: workoutManager.builder?.elapsedTime ?? 0,
                    showSubseconds: context.cadence == .live
                )
                HStack{
                    Text("❤️")
                        .scaleEffect(isAnimating ? 0.5 : 1)
                        .animation(repeatingAnimation, value: self.isAnimating)
                        .onAppear {
                            self.isAnimating = true
                        }
                    HearRateView()
                }

                Text("")
                    .frame(maxWidth: .infinity, minHeight: 2, alignment: .leading)
                    .background(
                        LinearGradient(gradient:
                                        Gradient(colors: [.gray, .white, .blue, .green, .yellow, .orange, .red]),
                                       startPoint: .leading, endPoint: .trailing)
                    )
                Text(
                    Measurement(
                        value:
                            (workoutManager.distance) /
                        (workoutManager.builder?.elapsedTime ?? 1),
                        unit: UnitSpeed.metersPerSecond
                    ).formatted(
                        .measurement(width: .abbreviated)
                    )
                )
                
                Text(
                    Measurement(
                        value: workoutManager.distance,
                        unit: UnitLength.meters
                    ).formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road
                        )
                    )
                )
            }
            .font(.system(.title2, design: .rounded)
                    .monospacedDigit()
                    .lowercaseSmallCaps()
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .scenePadding()
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView()
            .environmentObject(WorkoutManager())
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    
    var startDate: Date
    
    init(from startDate: Date) {
        self.startDate = startDate
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by:
                                    (mode == .lowFrequency ? 1.0 : 1.0 / 10.0)
        ).entries(from: startDate, mode: mode)
    }
}	

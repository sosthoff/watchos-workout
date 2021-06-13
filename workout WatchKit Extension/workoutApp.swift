//
//  workoutApp.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 10.06.21.
//

import SwiftUI

@main
struct workoutApp: App {
    @StateObject var workoutManager = WorkoutManager()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

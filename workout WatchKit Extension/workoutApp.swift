//
//  workoutApp.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 10.06.21.
//

import SwiftUI

@main
struct workoutApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

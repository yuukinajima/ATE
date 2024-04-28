//
//  AppDelegate.swift
//  Ex
//
//  Created by yuki najima on 2024/04/24.
//

import SwiftUI
import SwiftData
import AppKit

// required to close app on last window close
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}


@main
struct UIApp: App {

    init() {
        print(" INIT ")

//        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
//            print("Timer fired!")
//        }


    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SwiftUIView()
        }
        .modelContainer(sharedModelContainer)
    }
}

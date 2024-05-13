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

    var folderMonitor: FolderMonitor!

    init() {
        print(" INIT ")

//        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
//            print("Timer fired!")
//        }

        guard
            let downloadURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        else {
          fatalError("failed to get Document URL")
        }

        print("downloadURL \(downloadURL)")


        let targetUrl = URL(fileURLWithPath: "qa-132.html", relativeTo: downloadURL)
        print("target: \(targetUrl.absoluteString)")

        print(targetUrl.getTags() ?? "")

        let _ = targetUrl.addTags("red", "green")

        folderMonitor = FolderMonitor(url: downloadURL)

        folderMonitor.folderDidChange = { [] in
            print("folderDidChange")
        }
        folderMonitor.startMonitoring()
    }


    var body: some Scene {
        WindowGroup {
            //SwiftUIView()
            DebugView()
        }
        .modelContainer(sharedModelContainer)
    }
}


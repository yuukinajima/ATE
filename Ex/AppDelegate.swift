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
        
        folderMonitor = FolderMonitor(url: downloadURL)

        folderMonitor.folderDidChange = { [] in
            print("folderDidChange")
        }
        folderMonitor.startMonitoring()

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



import Foundation


class FolderMonitor {

    // MARK: Properties

    /// ディレクトリを監視するためのFileDescriptor
    private var monitoredFolderFileDescriptor: CInt = -1

    /// ディレクトリ内のファイル変更を処理するためのDispatchQueue
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)

    /// ファイル記述子に関連付けられたイベントを監視するDispatchSource
    private var folderMonitorSource: DispatchSourceFileSystemObject?

    /// 監視するディレクトリのURL
    let url: Foundation.URL

    /// ディレクトリに変更があった際に呼ばれるClosure
    var folderDidChange: (() -> Void)?

    // MARK: Initializers

    init(url: Foundation.URL) {
        self.url = url
    }

    // MARK: Monitoring

    /// Listen for changes to the directory (if we are not already).

    func startMonitoring() {
        guard folderMonitorSource == nil &&
                monitoredFolderFileDescriptor == -1
        else {
            return
        }
        // Open the directory referenced by URL for monitoring only.
        monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
        // Define a dispatch source monitoring the directory for additions, deletions, and renamings.
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor,
                                                                                                     eventMask: .write,
                                                                                                     queue: folderMonitorQueue)
        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChange?()
        }

        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
        folderMonitorSource?.setCancelHandler { [weak self] in
            guard let strongSelf = self else {
                return
            }
            close(strongSelf.monitoredFolderFileDescriptor)
            strongSelf.monitoredFolderFileDescriptor = -1
            strongSelf.folderMonitorSource = nil
        }

        // Start monitoring the directory via the source.
        folderMonitorSource?.resume()
    }

    /// Stop listening for changes to the directory, if the source has been created.
    func stopMonitoring() {
        folderMonitorSource?.cancel()
    }
}

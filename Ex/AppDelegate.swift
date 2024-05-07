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


    var body: some Scene {
        WindowGroup {
            //SwiftUIView()
            DebugView()
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

    var knowFiles: Set<URL> = []

    // MARK: Initializers

    init(url: Foundation.URL) {
        self.url = url
        
        guard let list = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles])
        else {
            print("ERR")
            return
        }
        for file in list {
            print(file)
            knowFiles.insert(file)
        }
        print(knowFiles)

        print("com.kumonosudou.ate.groups")



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
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: monitoredFolderFileDescriptor,
                eventMask: .write,
                queue: folderMonitorQueue)

        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler { [weak self] in
            let r = self?.ditectNewFile()
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


    func getWhereFrom(url: Foundation.URL) -> String? {
//        guard let values = try? url.resourceValues(forKeys: [.customMetadata]) else {
//            return nil
//        }
//        if let metadata = values.customMetadata {
//            if let whereFromData = metadata["com.apple.metadata:kMDItemWhereFroms"] as? Data {
//                if let whereFromString = String(data: whereFromData, encoding: .utf8) {
//                    return whereFromString
//                }
//            }
//        }
//
//
//        return nil
        return nil
    }


    func ditectNewFile() -> [URL]? {
        print("ditectNewFile")
        guard let currentFiles = getCurrenetFile(url: url) else{
            return nil
        }

        let newItems:Set = currentFiles.subtracting(knowFiles)

        for item in newItems {
            print(item)
            if let whereFrom = item.whereFrom() {
                print("whereFrom \(whereFrom)")
            } else {
                print("no wherefrom")
            }




//            guard let attributes = try? FileManager.default.attributesOfItem(atPath: item.path) else {
//                print("fial")
//                return nil
//            }
//            print("\n attributes")
//            let valueType = type(of: attributes)
//            print(valueType)
//            for attr in attributes {
//                let key = String(attr.key as NSString)
//
//
//                if key == "NSFileExtendedAttributes" {
//                    print("\n -- \n")
//                    print("keystring: \(key) ")
////                    print(attr.key)
////                    print(attr.value)
//                    let valueType = type(of: attr.value)
//
//                    if let extendedAttributes = attr.value as? [String: Any] ,
//                       let whereFromData = extendedAttributes["com.apple.metadata:kMDItemWhereFroms"] as? Data {
//                        print("extendedAttributes \(type(of:extendedAttributes))")
//
//                        print(whereFromData)
//                        print(type(of: whereFromData))
//
//                        let whereFromString = String(decoding: whereFromData, as: UTF8.self)
//
//                        print(whereFromData)
//
//                    }
//
//
//                    print(valueType)
//
//                    print(attr.value)
//                    print("\n -- \n")
//                } else {
//                    print("keystring: \(key) ")
//                }
//
//            }
//
//            if let whereFromData = attributes[.extendaa] as? Data {
//                 if let whereFromString = String(data: whereFromData, encoding: .utf8) {
//                     print(whereFromString)
//                 }
//             }

        }
        self.knowFiles = newItems
        

        return Array(newItems)
    }

    func getCurrenetFile(url: URL) -> Set<URL>? {
        guard let list = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles])
        else {
            print("ERR")
            return nil
        }
        return Set(list)
    }
}


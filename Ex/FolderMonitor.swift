//
//  FolderMonitor.swift
//  Ex
//
//  Created by yuki najima on 2024/05/13.
//

import Foundation
import SwiftData

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

    let modelContext = ModelContext(sharedModelContainer)

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

    func ditectNewFile() -> [URL]? {
        print("ditectNewFile")
        guard let currentFiles = getCurrenetFile(url: url) else{
            return nil
        }

        let newItems:Set = currentFiles.subtracting(knowFiles)

        for item in newItems {
            applyRule(item: item)
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

    func applyRule(item: URL){
        guard let whereFrom = item.whereFrom() else {
            return
        }

        guard let host = whereFrom.host else {
            print("nohost")
            return
        }

        var matched = false
        let ruleFetchDescriptor = FetchDescriptor<Rule>()
        guard let rules = try? modelContext.fetch(ruleFetchDescriptor) else {
            return
        }
        // todo


        if matched {
            addTag(url: item)
            return
        }

        let autoRuleFetchDescriptor = FetchDescriptor<AutoGenerateRule>()
        guard let autoGenerateRules = try? modelContext.fetch(autoRuleFetchDescriptor) else {
            return
        }
        
        if matched {
            addTag(url: item)
            return
        }
    }

    func addTag(url: URL){
        let request = FetchDescriptor<AppSettings>()
        let data = try? modelContext.fetch(request)
        guard let settings = data?.first else {
            return
        }
        let tag = settings.tag

        let currentTag = url.addTags(tag)
        print("currenttag: \(currentTag ?? [] )")

    }

}


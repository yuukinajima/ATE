//
//  SharedModelContainer.swift
//  ATE
//
//  Created by yuki najima on 2024/05/07.
//

import Foundation
import SwiftData

var sharedModelContainer: ModelContainer = {
    let schema = Schema([
        Item.self,
        VisitedUrl.self,
        SafariExtensionLog.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

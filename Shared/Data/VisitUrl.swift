//
//  VisitUrl.swift
//  Ex
//
//  Created by yuki najima on 2024/04/26.
//

import Foundation
import SwiftData

@Model
final class VisitedUrl {
    var url: String
    var domain: String
    var isAutoCollection: Bool
    var timestamp: Date

    init(url: String, domain: String, isAutoCollection:Bool = false, timestamp: Date = Date.now) {
        self.url = url
        self.domain = domain
        self.isAutoCollection = isAutoCollection
        self.timestamp = timestamp
    }
}

@Model
final class Rule {
    var matcher: String
    var timestamp: Date
    
    var isAutoCollection: Bool


    init(message: String, timestamp: Date = Date.now, isAutoCollection:Bool = false) {
        self.matcher = message
        self.timestamp = timestamp
        self.isAutoCollection = isAutoCollection
    }
}


@Model
final class SafariExtensionLog {
    var message: String
    var timestamp: Date

    init(message: String, timestamp: Date = Date.now) {
        self.message = message
        self.timestamp = timestamp
    }
}



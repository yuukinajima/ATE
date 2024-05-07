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

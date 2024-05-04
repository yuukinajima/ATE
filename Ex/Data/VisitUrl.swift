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

    init(url: String, domain: String) {
        self.url = url
        self.domain = domain
    }
}

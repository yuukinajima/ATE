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

    init(url: String) {
        self.url = url
    }
}

//
//  Item.swift
//  UI
//
//  Created by yuki najima on 2024/04/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

//
//  Item.swift
//  VeteransApp
//
//  Created by Jay Chauhan on 4/19/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var title: String
    var message: String
    var location: String
    
    init(timestamp: Date, title: String = "Event", message: String = "", location: String = "") {
        self.id = UUID()
        self.timestamp = timestamp
        self.title = title
        self.message = message
        self.location = location
    }
}

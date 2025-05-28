//
//  DataExampleItem.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//
import Foundation
import SwiftData

@Model
final class DataExampleItemSimple  {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Model
class DataExampleItemOrig: Identifiable, Hashable {
    var timestamp: Date

    
  // SwiftData will synthesize `id`. Just add:
  static func ==(lhs: DataExampleItemOrig, rhs: DataExampleItemOrig) -> Bool {
    lhs.id == rhs.id
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}



@Model
class DataExampleItem: Identifiable, Hashable {
    var id: UUID = UUID()
  var timestamp: Date

  init(timestamp: Date) { self.timestamp = timestamp }

  static func == (lhs: DataExampleItem, rhs: DataExampleItem) -> Bool {
    lhs.id == rhs.id
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

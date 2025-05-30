//
//  ToDoItems.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/29/25.
//
import Foundation
import SwiftData

@Model
class TodoList {
    var title: String
    
    @Relationship(deleteRule: .cascade)
    var items: [TodoItem] = []
    
    init(title: String) {
        self.title = title
    }
}
    
@Model
class TodoItem {
    var title: String
    var isCompleted: Bool = false
    
    init(title: String, isCompleted: Bool) {
        self.title = title
        self.isCompleted = isCompleted          
    }
    
}

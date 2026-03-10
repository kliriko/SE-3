//
//  TaskListModel.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import Foundation
import CoreData

enum TaskPriority: String, Codable, CaseIterable {
    case low, medium, high

    var label: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var color: String {
        switch self {
        case .low: "green"
        case .medium: "orange"
        case .high: "red"
        }
    }
}

struct MyTask: Identifiable, Codable {
    var name: String = ""
    var isDone: Bool = false
    var date: Date? = nil
    var id: String { name }
    var priority: TaskPriority = .medium
    var notificationEnabled: Bool = true
    var notify: Bool = true
    
    init(_ task: TodoTask) throws {
        self.name = task.name
        self.date = task.dueDate
        self.isDone = task.isDone
        self.priority = TaskPriority(rawValue: task.priority ?? "medium") ?? .medium
    }
    
    init(name: String, dueDate: Date?, priority: TaskPriority = .medium) {
        self.name = name
        self.date = dueDate
        self.priority = priority
    }
}

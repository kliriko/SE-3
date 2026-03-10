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

    var sortOrder: Int {
        switch self {
        case .high: 0
        case .medium: 1
        case .low: 2
        }
    }
}

enum SortType {
    case byDefault
    case byPriority
    case byDate

    var label: String {
        switch self {
        case .byDefault: "Default"
        case .byPriority: "Priority"
        case .byDate: "Date"
        }
    }
}

struct MyTask: Identifiable, Codable {
    var name: String = ""
    var isDone: Bool = false
    var date: Date? = nil
    var id: String { name }
    var priority: TaskPriority = .medium
    
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

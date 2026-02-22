//
//  TaskListModel.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import Foundation
import CoreData

struct MyTask: Identifiable, Codable {
    var name: String = ""
    var isDone: Bool = false
    var date: Date? = nil
    var subTasks: [SubTask] = []
    var id: String { name }
    var notificationEnabled: Bool = true
    var notify: Bool = true
    
    init(_ task: TodoTask) throws {
        self.name = task.name
        self.date = task.dueDate
        self.isDone = task.isDone
        self.notify = task.notify
        
        if let subTaskEntities = task.subTasks?.allObjects as? [TodoSubtask] {
            subTasks = subTaskEntities.map { SubTask(name: $0.name, isDone: $0.isDone) }
        } else {
            throw NSError(domain: "Failed to convert subTasks", code: 69, userInfo: nil)
        }
    }
    
    init(notification: MyNotification) {
        self.name = notification.title
        self.date = notification.dueDate
        self.isDone = false
        self.notify = true
    }
    
    init(name: String, dueDate: Date?) {
        self.name = name
        self.date = dueDate
    }
    
    init() {}
}

struct SubTask: Hashable, Identifiable, Codable {
    var name: String = ""
    var isDone: Bool = false
    var id: String { name }
    var notificationEnabled: Bool = true
    var notify: Bool = true
    
    init (name: String, isDone: Bool) {
        self.name = name
        self.isDone = isDone
    }
    
    init (_ task: TodoSubtask) throws {
        self.name = task.name
        self.isDone = task.isDone
    }
    
    init () { }
}

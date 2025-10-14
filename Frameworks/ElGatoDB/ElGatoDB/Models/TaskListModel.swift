//
//  TaskListModel.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import Foundation
import CoreData
import RealmSwift

class RealmTodoTask: Object {
    @Persisted var name: String = ""
    @Persisted var isDone: Bool = false
    @Persisted var date: Date? = nil
    @Persisted var subtasks: List<RealmTodoSubtask> = List<RealmTodoSubtask>()
    @Persisted var notify: Bool = true
    
    convenience init(_ name: String, date: Date? = nil, isDone: Bool) {
        self.init()
        self.name = name
        self.date = date
        self.isDone = isDone
    }
}

class RealmTodoSubtask: Object {
    @Persisted var name: String = ""
    @Persisted var isDone: Bool = false
    @Persisted var notify: Bool = true
}

struct Task: Identifiable {
    var name: String = ""
    var isDone: Bool = false
    var date: Date? = nil
    var subTasks: [SubTask] = []
    var id: String { name }
    var notificationEnabled: Bool = true
    var notify: Bool = true
    
    init(_ task: TodoTask) throws {
        name = task.name
        date = task.dueDate
        isDone = task.isDone
        notify = task.notify
        
        if let subTaskEntities = task.subTasks?.allObjects as? [TodoSubtask] {
            subTasks = subTaskEntities.map { SubTask(name: $0.name, isDone: $0.isDone) }
        } else {
            throw NSError(domain: "Failed to convert subTasks", code: 69, userInfo: nil)
        }
    }
    
    init(_ task: RealmTodoTask) throws {
        name = task.name
        date = task.date
        
        subTasks = task.subtasks.map { realmSubtask in
            SubTask(name: realmSubtask.name, isDone: realmSubtask.isDone)
        }
    }
    
    init(notification: Notification) {
        name = notification.title
        date = notification.dueDate
        isDone = false
        notify = true
    }
    
    init() {}
}

struct SubTask: Hashable, Identifiable {
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

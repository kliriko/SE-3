//
//  RealmManager.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import CoreData
import RealmSwift
 
class RealmManager: DrumNDataBase {
    let realm = try! Realm()
    
    func taskWithNameExists(_ name: String) -> Bool {
        let todos = realm.objects(RealmTodoTask.self)
        let todosWithName = todos.filter("name == %@", name)
        return !todosWithName.isEmpty
    }
    
    func getAllTasks() -> [Task] {
        let todos = realm.objects(RealmTodoTask.self)
        do {
            return try todos.map { try Task($0) }
        }
        catch {
            print("Failed to initialize task from Realm" + error.localizedDescription)
            return []
        }
    }
    
    func createTask(_ name: String, dueDate: Date?) throws {
        if taskWithNameExists(name) { throw DrumNDataBaseError.TaskAlreadyExists(name: name)}
        
        let todo = RealmTodoTask(name, date: dueDate, isDone: false)
        try! realm.write { // can it break?
            realm.add(todo)
        }
    }
    
    func getTask(_ name: String) throws -> Task {
        let todos = realm.objects(RealmTodoTask.self)
        let todosWithName = todos.where {
            $0.name == name
        }
        
        do {
            return try Task(todosWithName.first!)
        }
        catch {
            throw DrumNDataBaseError.TaskNotFound(name: name)
        }
    }
    
    func updateTask<rowType>(_ name: String, key: String, value: rowType) throws {
        let todos = realm.objects(RealmTodoTask.self)
        guard let todo = todos.where({ $0.name == name }).first else {
            throw DrumNDataBaseError.TaskNotFound(name: name)
        }
        switch key {
        case "name":
            guard let val = value as? String else {
                throw DrumNDataBaseError.InvalidFieldType(field: key)
            }
            todo.name = val
        case "isDone":
            guard let val = value as? Bool else {
                throw DrumNDataBaseError.InvalidFieldType(field: key)
            }
            try! realm.write { todo.isDone = val }
        case "date":
            guard value is Date? else {
                throw DrumNDataBaseError.InvalidFieldType(field: key)
            }
            todo.date = value as? Date
        case "notify":
            guard value is Bool? else {
                throw DrumNDataBaseError.InvalidFieldType(field: key)
            }
            // TODO: ???
            todo.notify = value as! Bool
        default:
            throw DrumNDataBaseError.InvalidFieldType(field: key)
        }
        
    }
    
    func deleteTask(_ name: String) throws {
        let todos = realm.objects(RealmTodoTask.self)
        let todosWithName = todos.where {
            $0.name == name
        }
        
        do {
            try realm.write {
                realm.delete(todosWithName)
            }
        } catch {
            throw DrumNDataBaseError.FailedToDelete(name: name)
        }
    }
    
    func createSubtask(_ subtaskName: String, in taskName: String) throws {
        guard let parentTask = realm.objects(RealmTodoTask.self)
            .filter("name == %@", taskName)
            .first else {
            throw DrumNDataBaseError.TaskNotFound(name: taskName)
        }
        
        if parentTask.subtasks.contains(where: { $0.name == subtaskName }) {
            throw DrumNDataBaseError.SubtaskAlreadyExists(name: subtaskName, in: taskName)
        }
        
        let newSubtask = RealmTodoSubtask()
        newSubtask.name = subtaskName
        newSubtask.isDone = false
        
        try realm.write {
            parentTask.subtasks.append(newSubtask)
        }
    }
    
    func getSubtask(_ subtaskName: String, in taskName: String) throws -> SubTask {
        guard let parentTask = realm.objects(RealmTodoTask.self)
            .filter("name == %@", taskName)
            .first else {
            throw DrumNDataBaseError.TaskNotFound(name: taskName)
        }
        
        guard let realmSubtask = parentTask.subtasks
            .filter("name == %@", subtaskName)
            .first else {
            throw DrumNDataBaseError.SubTaskNotFound(name: subtaskName, in: taskName)
        }
        
        return SubTask(name: realmSubtask.name, isDone: realmSubtask.isDone)
    }
    
    func updateSubtask<ValueType>(
        _ subtaskName: String,
        in taskName: String,
        key: String,
        value: ValueType
    ) throws {
        guard let parentTask = realm.objects(RealmTodoTask.self)
            .filter("name == %@", taskName)
            .first else {
            throw DrumNDataBaseError.TaskNotFound(name: taskName)
        }
        
        guard let subtask = parentTask.subtasks
            .filter("name == %@", subtaskName)
            .first else {
            throw DrumNDataBaseError.SubTaskNotFound(name: subtaskName, in: taskName)
        }
        
        try realm.write {
            switch key {
            case "name":
                guard let newName = value as? String else {
                    throw DrumNDataBaseError.InvalidFieldType(field: key)
                }
                subtask.name = newName
                
            case "isDone":
                guard let isDone = value as? Bool else {
                    throw DrumNDataBaseError.InvalidFieldType(field: key)
                }
                subtask.isDone = isDone
                
            default:
                throw DrumNDataBaseError.InvalidFieldType(field: key)
            }
        }
    }
    
    func deleteSubtask(_ subtaskName: String, in taskName: String) throws {
        guard let parentTask = realm.objects(RealmTodoTask.self)
            .filter("name == %@", taskName)
            .first else {
            throw DrumNDataBaseError.TaskNotFound(name: taskName)
        }
        
        guard let subtaskToDelete = parentTask.subtasks
            .filter("name == %@", subtaskName)
            .first else {
            throw DrumNDataBaseError.SubTaskNotFound(name: subtaskName, in: taskName)
        }
        
        try realm.write {
            if let index = parentTask.subtasks.firstIndex(of: subtaskToDelete) {
                parentTask.subtasks.remove(at: index)
            }
            realm.delete(subtaskToDelete)
        }
    }
}

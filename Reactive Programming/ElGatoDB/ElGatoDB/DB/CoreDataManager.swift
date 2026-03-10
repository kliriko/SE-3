//
//  CoreDataManager.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import CoreData
import Combine

class CoreDataManager: DrumNDataBase {
    let context: NSManagedObjectContext
    
    private let tasksSubject = CurrentValueSubject<[MyTask], Never>([])
    var tasksPublisher: AnyPublisher<[MyTask], Never> {
        tasksSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        let tasks = getAllTasks()
        tasksSubject.send(tasks)
    }
    
    deinit { cancellables.removeAll() }
    
    private func handleContextChange() {
        let tasks = getAllTasks()
        tasksSubject.send(tasks)
    }
    
    func taskExists(_ name: String) -> Bool {
        do {
            _ = try getTask(name)
            return true
        } catch {
            return false
        }
    }
    
    func getAllTasks() -> [MyTask] {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        return try! context.fetch(fetchRequest).map { try! MyTask($0)}
    }
    
    func createTask(_ name: String, dueDate: Date? = nil, priority: TaskPriority = .medium) throws {
        if taskExists(name) {
            throw DrumNDataBaseError.TaskAlreadyExists(name: name)
        } else {
            let task = TodoTask(context: context)
            task.name = name
            task.isDone = false
            task.dueDate = dueDate
            task.priority = priority.rawValue
            
            do { 
                try context.save()
                handleContextChange()
            } catch { throw error }
        }
    }
        
    func getTask(_ name: String) throws -> MyTask {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            guard let task = try context.fetch(fetchRequest).first else {
                throw DrumNDataBaseError.TaskNotFound(name: name)
            }
            return try MyTask(task)
        } catch {
            throw DrumNDataBaseError.TaskNotFound(name: name)
        }
    }
    
    func updateTask<rowType>(_ name: String, key: String, value: rowType) throws {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        guard let taskObject = try context.fetch(fetchRequest).first else {
            throw DrumNDataBaseError.TaskNotFound(name: name)
        }
        taskObject.setValue(value, forKey: key)
        try context.save()
        handleContextChange()
    }
    
    func editTask(oldName: String, name: String, dueDate: Date?, priority: TaskPriority) throws {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", oldName)
        guard let taskObject = try context.fetch(fetchRequest).first else {
            throw DrumNDataBaseError.TaskNotFound(name: oldName)
        }
        taskObject.name = name
        taskObject.dueDate = dueDate
        taskObject.priority = priority.rawValue
        try context.save()
        handleContextChange()
    }
    
    func deleteTask(_ name: String) throws {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        guard let taskObject = try context.fetch(fetchRequest).first else {
            throw DrumNDataBaseError.TaskNotFound(name: name)
        }
        
        context.delete(taskObject)
        try context.save()
        handleContextChange()
    }
}

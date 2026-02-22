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
    
    func subtaskExists(_ name: String, in taskName: String) -> Bool { //???
        do {
            let task = try getTask(taskName)
            return task.subTasks.contains(where: { $0.name == name })
        } catch {
            return false
        }
    }
    
    func getAllTasks() -> [MyTask] {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        return try! context.fetch(fetchRequest).map { try! MyTask($0)}
    }
    
    func createTask(_ name: String, dueDate: Date? = nil) throws {
        if taskExists(name) {
            throw DrumNDataBaseError.TaskAlreadyExists(name: name)
        } else {
            let task = TodoTask(context: context)
            task.name = name
            task.isDone = false
            task.dueDate = dueDate
            task.notify = true
            
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
    
    func createSubtask(_ name: String, in taskName: String) throws {
        if (subtaskExists(name, in: taskName)) {
            throw DrumNDataBaseError.SubtaskAlreadyExists(name: name, in: taskName)
        } else {
            let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", taskName)
            
            do {
                let parentTask = try context.fetch(fetchRequest).first
                
                let subtask = TodoSubtask(context: context)
                subtask.name = name
                subtask.isDone = false
                
                parentTask?.addToSubTasks(subtask)
                
                try! context.save()
                handleContextChange()
                
            } catch {
                throw DrumNDataBaseError.TaskNotFound(name: taskName)
            }
        }
    }
    
    func getSubtask(_ name: String, in taskName: String) throws -> SubTask {
        do {
            let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", taskName)
            guard let parentTask = try context.fetch(fetchRequest).first else {
                throw DrumNDataBaseError.TaskNotFound(name: taskName)
            }
            guard let subTasksSet = parentTask.subTasks as? Set<TodoSubtask> else {
                throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
            }
            guard let foundSubtask = subTasksSet.first(where: { $0.name == name }) else {
                throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
            }
            return try SubTask(foundSubtask)
        } catch {
            throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
        }
    }
    
    func updateSubtask<rowType>(_ name: String, in taskName: String, key: String, value: rowType) throws {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", taskName)
        guard let parentTask = try context.fetch(fetchRequest).first else {
            throw DrumNDataBaseError.TaskNotFound(name: taskName)
        }
        guard let subTasksSet = parentTask.subTasks as? Set<TodoSubtask> else {
            throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
        }
        guard let subtask = subTasksSet.first(where: { $0.name == name }) else {
            throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
        }
        subtask.setValue(value, forKey: key)
        try context.save()
        handleContextChange()
    }
    
    func deleteSubtask(_ name: String, in taskName: String) throws {
        let fetchRequest: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", taskName)
        guard let parentTask = try context.fetch(fetchRequest).first else {
            throw DrumNDataBaseError.TaskNotFound(name: taskName)
        }
        guard let subTasksSet = parentTask.subTasks as? Set<TodoSubtask> else {
            throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
        }
        guard let subtask = subTasksSet.first(where: { $0.name == name }) else {
            throw DrumNDataBaseError.SubTaskNotFound(name: name, in: taskName)
        }
        parentTask.removeFromSubTasks(subtask)
        context.delete(subtask)
        do { 
            try context.save()
            handleContextChange()
        } catch { 
            throw DrumNDataBaseError.FailedToDelete(name: name) 
        }
    }
}

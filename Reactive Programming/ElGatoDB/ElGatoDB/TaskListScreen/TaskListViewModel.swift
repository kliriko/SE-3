//
//  TaskListViewModel.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class TaskListViewModel: ObservableObject {
    @Published var tasks: [MyTask] = []
    @Published var filteredTasks: [MyTask] = []
    @Published var presentTaskPopup: Bool = false
    @Published var verified: Bool = false
    @Published var inputFieldText = ""
    
    var dataManager: CoreDataManager!
    
    let dateFormatter = DateFormatter()
    var lastTaskName: String = ""
    
    let taskToggleSubject = PassthroughSubject<MyTask, Never>()
    let taskDeleteSubject = PassthroughSubject<String, Never>()
    let taskCreateSubject = PassthroughSubject<(name: String, dueDate: Date?, priority: TaskPriority), Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        dateFormatter.dateFormat = "MMM d, h:mm a"
    }
    
    func initContext(context: NSManagedObjectContext) {
        dataManager = CoreDataManager(context)
        tasks = dataManager.getAllTasks()
        filteredTasks = tasks
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.tasksPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        
        $inputFieldText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .combineLatest($tasks)
            .map { query, tasks in
                guard !query.isEmpty else { return tasks }
                return tasks.filter { $0.name.localizedCaseInsensitiveContains(query) }
            }
            .assign(to: &$filteredTasks)
        
        taskToggleSubject
            .sink { [weak self] task in
                Task {
                    do { try self?.dataManager.updateTask(task.name, key: "isDone", value: !task.isDone) } catch {
                        print("Failed to update isDone for task \(task.name): \(error)")
                    }
                }
            }
            .store(in: &cancellables)
        
        taskDeleteSubject
            .sink { [weak self] taskName in
                do { try self?.dataManager.deleteTask(taskName) } catch {
                    print("Failed to delete task \(taskName): \(error)")
                }
            }
            .store(in: &cancellables)
        
        taskCreateSubject
            .sink { [weak self] taskInfo in
                do {  try self?.dataManager.createTask(taskInfo.name, dueDate: taskInfo.dueDate, priority: taskInfo.priority) } catch {
                    print("Failed to create task \(taskInfo.name): \(error)")
                }
            }
            .store(in: &cancellables)
    }
}

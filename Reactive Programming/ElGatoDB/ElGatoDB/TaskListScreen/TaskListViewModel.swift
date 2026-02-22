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
    @Published var presentTaskPopup: Bool = false
    @Published var presentSubtaskPopup: Bool = false
    @Published var verified: Bool = false
    
    var dataManager: CoreDataManager!
    
    let dateFormatter = DateFormatter()
    var lastTaskName: String = ""
    
    let taskToggleSubject = PassthroughSubject<MyTask, Never>()
    let taskDeleteSubject = PassthroughSubject<String, Never>()
    let taskCreateSubject = PassthroughSubject<(name: String, dueDate: Date?), Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        dateFormatter.dateFormat = "MMM d, h:mm a"
    }
    
    func initContext(context: NSManagedObjectContext) {
        dataManager = CoreDataManager(context)
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.tasksPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        
        taskToggleSubject
            .sink { [weak self] task in Task { await self?.toggleTaskIsDone(task) } }
            .store(in: &cancellables)
        
        taskDeleteSubject
            .sink { [weak self] taskName in
                guard let self = self else { return }
                do {
                    try self.dataManager.deleteTask(taskName)
                } catch {
                    print("Failed to delete task \(taskName): \(error)")
                }
            }
            .store(in: &cancellables)
        
        taskCreateSubject
            .sink { [weak self] taskInfo in
                guard let self = self else { return }
                do {
                    try self.dataManager.createTask(taskInfo.name, dueDate: taskInfo.dueDate)
                } catch {
                    print("Failed to create task \(taskInfo.name): \(error)")
                }
            }
            .store(in: &cancellables)
        
        tasks = dataManager.getAllTasks()
    }
    
    func toggleTaskIsDone(_ task: MyTask) async {
        do { try dataManager.updateTask(task.name, key: "isDone", value: !task.isDone) } catch {
            print("Failed to update isDone for task \(task.name): \(error)")
        }
    }
    
    func toggleSubtaskIsDone(_ subtask: SubTask, in parentTask: MyTask) async {
        do {
            try dataManager.updateSubtask(subtask.name, in: parentTask.name, key: "isDone", value: !subtask.isDone)
        } catch {
            print("Failed to update isDone for subtask \(subtask.name) in \(parentTask.name): \(error)")
        }
    }
    
    func createSubtask(name: String, in parentTaskName: String) async {
        do {
            try dataManager.createSubtask(name, in: parentTaskName)
        } catch {
            print("Failed to create subtask \(name) in \(parentTaskName): \(error)")
        }
    }
}

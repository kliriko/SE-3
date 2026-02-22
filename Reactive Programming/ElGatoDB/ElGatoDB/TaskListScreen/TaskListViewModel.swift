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
    
    let subtaskToggleSubject = PassthroughSubject<(subtask: SubTask, in: MyTask), Never>()
    let subtaskDeleteSubject = PassthroughSubject<(name: String, in: String), Never>()
    let subtaskCreateSubject = PassthroughSubject<(name: String, in: String), Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        dateFormatter.dateFormat = "MMM d, h:mm a"
    }
    
    func initContext(context: NSManagedObjectContext) {
        dataManager = CoreDataManager(context)
        tasks = dataManager.getAllTasks()
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.tasksPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        
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
                do {  try self?.dataManager.createTask(taskInfo.name, dueDate: taskInfo.dueDate) } catch {
                    print("Failed to create task \(taskInfo.name): \(error)")
                }
            }
            .store(in: &cancellables)
        
        subtaskToggleSubject
            .sink { [weak self] info in
                Task {
                    do { try self?.dataManager.updateSubtask(info.subtask.name, in: info.in.name, key: "isDone", value: !info.subtask.isDone) } catch {
                        print("Failed to update isDone for subtask \(info.subtask.name) in \(info.in.name): \(error)")
                    }
                }
            }
            .store(in: &cancellables)
        
        subtaskDeleteSubject
            .sink { [weak self] info in
                do { try self?.dataManager.deleteSubtask(info.name, in: info.name) } catch {
                    print("Failed to delete subtask \(info.name) in \(info.in): \(error)")
                }
            }
            .store(in: &cancellables)
        
        subtaskCreateSubject
            .sink { [weak self] info in
                Task {
                    do { try self?.dataManager.createSubtask(info.name, in: info.in) } catch {
                        print("Failed to create subtask \(info.name) in \(info.in): \(error)")
                    }
                }
            }
            .store(in: &cancellables)
    }
}

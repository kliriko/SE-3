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
    @Published var sortType: SortType = .byDefault
    
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
            .combineLatest($tasks, $sortType)
            .map { [unowned self] query, tasks, sortType in
                self.sorted(self.filtered(tasks, by: query), by: sortType)
            }
            .assign(to: &$filteredTasks)
        
        taskToggleSubject
            .sink { [weak self] task in
                try? self?.dataManager.updateTask(task.name, key: "isDone", value: !task.isDone)
            }
            .store(in: &cancellables)
        
        taskDeleteSubject
            .sink { [weak self] taskName in
                try? self?.dataManager.deleteTask(taskName)
            }
            .store(in: &cancellables)
        
        taskCreateSubject
            .sink { [weak self] taskInfo in
                try? self?.dataManager.createTask(taskInfo.name, dueDate: taskInfo.dueDate, priority: taskInfo.priority)
            }
            .store(in: &cancellables)
    }
    
    private func filtered(_ tasks: [MyTask], by query: String) -> [MyTask] {
        guard !query.isEmpty else { return tasks }
        return tasks.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    private func sorted(_ tasks: [MyTask], by sortType: SortType) -> [MyTask] {
        switch sortType {
        case .byDefault:
            return tasks.sorted { lhs, rhs in
                let criteria: [(lhs: Int, rhs: Int)] = [
                    (lhs.isDone ? 1 : 0, rhs.isDone ? 1 : 0),
                    (lhs.priority.sortOrder, rhs.priority.sortOrder),
                    (Int((lhs.date ?? .distantFuture).timeIntervalSince1970),
                     Int((rhs.date ?? .distantFuture).timeIntervalSince1970)),
                    (0, lhs.name.localizedCompare(rhs.name) == .orderedAscending ? 1 : 0)
                ]
                for (lhsCriteria, rhsCriteria) in criteria {
                    if lhsCriteria == rhsCriteria { continue }
                    return lhsCriteria < rhsCriteria
                }
                return false
            }
        case .byPriority:
            return tasks.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .byDate:
            return tasks.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
        }
    }
}

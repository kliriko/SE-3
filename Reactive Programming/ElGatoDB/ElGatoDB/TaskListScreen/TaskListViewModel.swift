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

enum FormState {
    case none
    case create
    case edit(MyTask)
}

class TaskListViewModel: ObservableObject {
    @Published var tasks: [MyTask] = []
    @Published var filteredTasks: [MyTask] = []
    @Published var inputFieldText = ""
    @Published var sortType: SortType = .byDefault
    
    @Published var formState: FormState = .none
    
    var showFormSheet: Binding<Bool> {
        Binding(
            get: {
                if case .none = self.formState { return false }
                return true
            },
            set: { if !$0 { self.formState = .none } }
        )
    }
    
    var dataManager: CoreDataManager!
    
    let dateFormatter = DateFormatter()
    var lastTaskName: String = ""
    
    let taskToggleSubject = PassthroughSubject<MyTask, Never>()
    let taskDeleteSubject = PassthroughSubject<String, Never>()
    let taskEditSubject = PassthroughSubject<MyTask, Never>()
    
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
    
    func presentCreateForm() {
        formState = .create
    }
    
    func presentEditForm(for task: MyTask) {
        formState = .edit(task)
    }
    
    func makeFormViewModel() -> TaskFormViewModel? {
        switch formState {
        case .none: return nil
        case .create: return TaskFormViewModel(dataManager: dataManager)
        case .edit(let task): return TaskFormViewModel(dataManager: dataManager, task: task)
        }
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
        
        taskEditSubject
            .sink { [weak self] task in
                self?.presentEditForm(for: task)
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

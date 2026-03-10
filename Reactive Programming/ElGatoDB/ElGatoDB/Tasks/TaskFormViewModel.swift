//
//  TaskFormViewModel.swift
//  ElGatoDB
//
//  Created by Володимир on 11.03.2026.
//

import Foundation
import Combine

class TaskFormViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var date: Date? = nil
    @Published var priority: TaskPriority = .medium
    
    let saveSubject = PassthroughSubject<Void, Never>()
    let didSave = PassthroughSubject<Void, Never>()
    
    private let editingTask: MyTask?
    private let dataManager: CoreDataManager
    private var cancellables = Set<AnyCancellable>()
    
    var isEditing: Bool { editingTask != nil }
    var title: String { isEditing ? "Edit Task" : "New Task" }
    var buttonLabel: String { isEditing ? "Save" : "Add task" }
    
    init(dataManager: CoreDataManager, task: MyTask? = nil) {
        self.dataManager = dataManager
        self.editingTask = task
        
        if let task {
            self.taskName = task.name
            self.date = task.date
            self.priority = task.priority
        }
        
        saveSubject
            .sink { [weak self] in self?.save() }
            .store(in: &cancellables)
    }
    
    private func save() {
        guard !taskName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        if let editingTask {
            try? dataManager.editTask(
                oldName: editingTask.name,
                name: taskName,
                dueDate: date,
                priority: priority
            )
        } else {
            try? dataManager.createTask(taskName, dueDate: date, priority: priority)
        }
        
        didSave.send()
    }
}

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
    
    var notificationManager = NotificationManager()
    var dataManager: DrumNDataBase!
    
    let dateFormatter = DateFormatter()
    var lastTaskName: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let taskUpdateTrigger = PassthroughSubject<Void, Never>()
    
    init(usingRealm: Bool) {
        dateFormatter.dateFormat = "MMM d, h:mm a"
        setupBindings()
    }
    
    private func setupBindings() {
        taskUpdateTrigger
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.updateTasks()
                }
            }
            .store(in: &cancellables)
    }
    
    func initContext(context: NSManagedObjectContext) {
        dataManager = CoreDataManager(context)
    }
    
    func updateTasks() async {
        tasks = dataManager.getAllTasks()
    }
    
    func taskExists(_ name: String) -> Bool {
        !dataManager.getAllTasks().filter({$0.name == name}).isEmpty
    }
    
    func subtaskExists(_ name: String) -> Bool {
        let allSubtasks: [SubTask] = tasks.flatMap(\.subTasks)
        return !allSubtasks.filter({$0.name == name}).isEmpty
    }
    
    func toggleTaskIsDone(_ task: MyTask) async {
        do {
            try dataManager.updateTask(task.name, key: "isDone", value: !task.isDone)
            taskUpdateTrigger.send()
        } catch {
            print("Failed to update isDone for task \(task.name): \(error)")
        }
    }
    
    func toggleSubtaskIsDone(_ subtask: SubTask, in parentTask: MyTask) async{
        do {
            try dataManager.updateSubtask(subtask.name, in: parentTask.name, key: "isDone", value: !subtask.isDone)
            taskUpdateTrigger.send()
        } catch {
            print("Failed to update isDone for subtask \(subtask.name) in \(parentTask.name): \(error)")
        }
    }
}

@ViewBuilder func coolDeleteButton(closure: @escaping () throws -> Void) -> some View {
    Button("Burn") {
        do {
            try closure()
        } catch {
            print("Deletion failed")
        }
    }
}

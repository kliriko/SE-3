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
    @Published var tasks: [Task] = []
    @Published var presentTaskPopup: Bool = false
    @Published var presentSubtaskPopup: Bool = false
    var notificationCenter = NotificationCenter()
    var manager: DrumNDataBase!
    
    private var usingRealm: Bool
    
    let dateFormatter = DateFormatter()
    var lastTaskName: String = ""
    
    init(usingRealm: Bool) {
        self.usingRealm = usingRealm
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }
    
    func initContext(context: NSManagedObjectContext) {
        if usingRealm {
            manager = RealmManager()
        } else {
            manager = CoreDataManager(context)
        }
    }
    
    func updateTasks() {
        tasks = manager.getAllTasks()
    }
    
    func taskExists(_ name: String) -> Bool {
        !manager.getAllTasks().filter({$0.name == name}).isEmpty
    }
    
    func subtaskExists(_ name: String) -> Bool {
        let allSubtasks: [SubTask] = tasks.flatMap(\.subTasks)
        return !allSubtasks.filter({$0.name == name}).isEmpty
    }
    
    func toggleTaskIsDone(_ task: Task) {
        do {
            try manager.updateTask(task.name, key: "isDone", value: !task.isDone)
            updateTasks()
        } catch {
            print("Failed to update isDone for task \(task.name): \(error)")
        }
    }

    func toggleSubtaskIsDone(_ subtask: SubTask, in parentTask: Task) {
        do {
            try manager.updateSubtask(subtask.name, in: parentTask.name, key: "isDone", value: !subtask.isDone)
            updateTasks()
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


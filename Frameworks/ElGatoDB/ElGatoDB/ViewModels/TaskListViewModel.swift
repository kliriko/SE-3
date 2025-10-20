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
    
    @Published var verified = false
    @Published var protectedTasks: [MyTask] = []
    @Published var authManager: AuthManager = AuthManager()
    
    var notificationCenter = MyNotificationCenter()
    var dataManager: DrumNDataBase!
    
    private var usingRealm: Bool
    
    let dateFormatter = DateFormatter()
    var lastTaskName: String = ""
    
    init(usingRealm: Bool) {
        self.usingRealm = usingRealm
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            print("terminate")
            self.verified = false
        }
    }
    
    func initContext(context: NSManagedObjectContext) {
        if usingRealm {
            dataManager = RealmManager()
        } else {
            dataManager = CoreDataManager(context)
        }
    }
    
    func updateTasks() async {
        tasks = dataManager.getAllTasks()
        protectedTasks = await authManager.getProtectedTasks()
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
            Task {
                await updateTasks()
            }
        } catch {
            print("Failed to update isDone for task \(task.name): \(error)")
        }
    }

    func toggleSubtaskIsDone(_ subtask: SubTask, in parentTask: MyTask) async{
        do {
            try dataManager.updateSubtask(subtask.name, in: parentTask.name, key: "isDone", value: !subtask.isDone)
            Task {
                await updateTasks()
            }
            
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


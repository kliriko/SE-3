//
//  TaskRowView.swift
//  ElGatoDB
//
//  Created by Володимир on 12.10.2025.
//

import SwiftUI

struct TaskRowView: View {
    var viewModel: TaskListViewModel
    @State var task: Task
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.presentSubtaskPopup = true
                viewModel.lastTaskName = task.name
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(.green))
            })
            .clipped()
            .buttonStyle(.borderless)
            
            Text(task.name)
            Spacer()

            if let date = task.date {
                Text(viewModel.dateFormatter.string(from: date))
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.blue))
            }
            
            Toggle("Notify", isOn: $task.notify)
                            .onChange(of: task.notify) { _, newValue in
                                guard viewModel.tasks.contains(where: { $0.id == task.id }) else { return }
                                
                                do {
                                    try viewModel.manager.updateTask(task.name, key: "notify", value: newValue)
                                    
                                    DispatchQueue.main.async {
                                        if newValue {
                                            viewModel.notificationCenter.cancelNotification(taskName: task.name)
                                            viewModel.notificationCenter.scheduleLocalNotification(
                                                title: task.name,
                                                body: "Task is due soon!",
                                                date: task.date ?? Date()
                                            )
                                        } else {
                                            viewModel.notificationCenter.cancelNotification(taskName: task.name)
                                        }
                                    }
                                } catch {
                                    print("Failed to toggle notify: \(error)")
                                }
                            }

            Toggle(isOn: $task.isDone) { }
                .toggleStyle(iOSCheckboxToggleStyle())
                .onChange(of: task.isDone) { _, newValue in
                    do {
                        try viewModel.manager.updateTask(task.name, key: "isDone", value: newValue)
                        viewModel.updateTasks()
                    } catch {
                        print("Failed to toggle isDone: \(error)")
                    }
                }
        }
    }
}

#Preview {
    TaskRowView(viewModel: TaskListViewModel(usingRealm: false), task: Task())
}

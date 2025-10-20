//
//  SecureTaskRowView.swift
//  ElGatoDB
//
//  Created by Володимир on 20.10.2025.
//

import SwiftUI

struct SecureTaskRowView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State var task: MyTask
    
    var body: some View {
        HStack {
            Button(action: {
                task.isDone.toggle()
                do {
                    try viewModel.authManager.addProtectedTask(task)
                    print("Toggled isDone for \(task.name)")
                    
                    Task { await viewModel.updateTasks() }
                } catch {
                    print("Failed to toggle isDone:", error)
                }
            }) {
                if task.isDone {
                    Text(task.name)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                } else {
                    Text(task.name)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            if let date = task.date {
                Text(viewModel.dateFormatter.string(from: date))
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.blue))
            }

            Toggle(isOn: $task.notify) { }
                .onChange(of: task.notify) { _, newValue in
                    Task {
                        var updatedTask = task
                        updatedTask.notify = newValue
                        
                        do {
                            try viewModel.authManager.addProtectedTask(updatedTask)
                            
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
                            print("Failed to toggle notify:", error)
                        }
                    }
                }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                do {
                    try viewModel.authManager.deleteProtectedTask(id: task.id)
                    print("🗑️ Deleted secure task:", task.name)
                    Task { await viewModel.updateTasks() }
                } catch {
                    print("Failed to delete secure task:", error)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

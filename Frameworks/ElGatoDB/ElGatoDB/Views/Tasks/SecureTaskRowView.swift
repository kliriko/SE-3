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
            Image(systemName: "shield")
                
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

            Button(action: {
                viewModel.toggleNotificationProtected(task: $task)
            }) {
                Image(systemName: task.notify ? "bell.fill" : "bell.slash")
                    .foregroundColor(task.notify ? .yellow : .gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                do {
                    try viewModel.authManager.deleteProtectedTask(id: task.id)
                    print("Deleted secure task:", task.name)
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

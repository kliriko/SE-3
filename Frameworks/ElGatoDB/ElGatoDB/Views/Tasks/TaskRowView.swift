//
//  TaskRowView.swift
//  ElGatoDB
//
//  Created by Володимир on 12.10.2025.
//

import SwiftUI

struct TaskRowView: View {
    var viewModel: TaskListViewModel
    @State var task: MyTask
    
    var body: some View {
        HStack {
            Button(action: {
                do {
                    try viewModel.dataManager.updateTask(task.name, key: "isDone", value: !task.isDone)
                    task.isDone.toggle()
                    Task {
                        await viewModel.updateTasks()
                    }
                } catch {
                    print("Failed to toggle isDone: \(error)")
                }
            }) {
                if task.isDone {
                    Text(task.name)
                        .strikethrough()
                } else {
                    Text(task.name)
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
                viewModel.toggleNotification(task: $task)
            }) {
                Image(systemName: task.notify ? "bell.fill" : "bell.slash")
                    .foregroundColor(task.notify ? .yellow : .gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing){
            Button(action: {
                do {
                    try viewModel.dataManager.deleteTask(task.name)
                    Task {
                        await viewModel.updateTasks()
                    }
                }
                catch {
                    print("failed to delete task")
                }
            }, label: {
                Text("Delete")
            })
            .tint(.red)
        }
        .swipeActions(edge: .leading){
            Button(action: {
                viewModel.presentSubtaskPopup = true
                viewModel.lastTaskName = task.name
            }, label: {
                Text("Subtask")
            })
            .tint(.green)
        }
    }
}

#Preview {
    TaskRowView(viewModel: TaskListViewModel(usingRealm: false), task: MyTask())
}

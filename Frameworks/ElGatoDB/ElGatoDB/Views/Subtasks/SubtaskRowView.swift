//
//  SubtaskRowView.swift
//  ElGatoDB
//
//  Created by Володимир on 12.10.2025.
//

import SwiftUI

struct SubtaskRowView: View {
    var viewModel: TaskListViewModel
    @State var subtask: SubTask
    @Binding var task: Task
    
    var body: some View {
        HStack {
            Button(action: {
                do {
                    try viewModel.dataManager.updateSubtask(subtask.name, in: task.name, key: "isDone", value: !subtask.isDone)
                    subtask.isDone.toggle()
                    viewModel.updateTasks()
                } catch {
                    print("Failed to toggle isDone: \(error)")
                }
            }) {
                if subtask.isDone {
                    Text("      -" + subtask.name)
                        .strikethrough()
                } else {
                    Text("      -" + subtask.name)
                }
            }
            .buttonStyle(.plain)
            Spacer()
            
            Toggle(isOn: $subtask.notify) { }
            .onChange(of: task.notify) { _, newValue in
//                guard viewModel.tasks.contains(where: { $0.id == task.id }) else { return }
//                
//                do {
//                    try viewModel.manager.updateTask(task.name, key: "notify", value: newValue)
//                    
//                    DispatchQueue.main.async {
//                        if newValue {
//                            viewModel.notificationCenter.cancelNotification(taskName: task.name)
//                            viewModel.notificationCenter.scheduleLocalNotification(
//                                title: task.name,
//                                body: "Task is due soon!",
//                                date: task.date ?? Date()
//                            )
//                        } else {
//                            viewModel.notificationCenter.cancelNotification(taskName: task.name)
//                        }
//                    }
//                } catch {
//                    print("Failed to toggle notify: \(error)")
//                }
            }
            
//            CoolDeleteButton {
//                do {
//                    try viewModel.manager.deleteSubtask(subtask.name, in: task.name)
//                    viewModel.updateTasks()
//                    viewModel.presentSubtaskPopup = false
//                }
//                catch {
//                    print("failed to delete subtask")
//                }
//            }
        }
        .swipeActions(edge: .trailing){
            Button(action: {
                do {
                    try viewModel.dataManager.deleteSubtask(subtask.name, in: task.name)
                    viewModel.updateTasks()
                }
                catch {
                    print("failed to delete task")
                }
            }, label: {
                Text("Delete")
            })
            .tint(.red)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SubtaskRowView(viewModel: TaskListViewModel(usingRealm: false), subtask: SubTask(), task: .constant(Task()))
}

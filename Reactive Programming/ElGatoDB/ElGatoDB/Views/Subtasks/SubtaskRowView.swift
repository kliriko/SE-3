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
    @Binding var task: MyTask
    
    var body: some View {
        HStack {
            Button(action: {
                do {
                    try viewModel.dataManager.updateSubtask(subtask.name, in: task.name, key: "isDone", value: !subtask.isDone)
                    subtask.isDone.toggle()
                    Task {
                        await viewModel.updateTasks()
                    }
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
                .swipeActions(edge: .trailing){
                    Button(action: {
                        do {
                            try viewModel.dataManager.deleteSubtask(subtask.name, in: task.name)
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
                .padding(.vertical, 5)
        }
    }
}

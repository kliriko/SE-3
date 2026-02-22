//
//  SubtaskRowView.swift
//  ElGatoDB
//
//  Created by Володимир on 12.10.2025.
//

import SwiftUI
import Combine

struct SubtaskRowView: View {
    var viewModel: TaskListViewModel
    var subtask: SubTask
    @Binding var task: MyTask
    
    var body: some View {
        HStack {
            Button(action: {
                Task { viewModel.subtaskToggleSubject.send((subtask, in: task)) }
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
        }
        .swipeActions(edge: .trailing){
            Button(action: {
                Task {
                    try? viewModel.dataManager.deleteSubtask(subtask.name, in: task.name)
                }
            }, label: {
                Text("Delete")
            })
            .tint(.red)
        }
    }
}

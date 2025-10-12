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
            Text("      – " + subtask.name)
            Spacer()
            Toggle(isOn: Binding(
                get: { subtask.isDone },
                set: { newValue in
                    do {
                        try viewModel.manager.updateSubtask(subtask.name, in: task.name, key: "isDone", value: newValue)
                        subtask.isDone = newValue
                        viewModel.updateTasks()
                    } catch {
                        print("Failed to toggle subtask isDone: \(error)")
                    }
                })
            ) {
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            Button(action: {
                do {
                    try viewModel.manager.deleteSubtask(subtask.name, in: task.name)
                    viewModel.updateTasks()
                    viewModel.presentSubtaskPopup = false
                }
                catch {
                    print("failed to delete subtask")
                }
            }, label: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(.red))
            })
            .clipped().buttonStyle(.borderless)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SubtaskRowView(viewModel: TaskListViewModel(usingRealm: false), subtask: SubTask(), task: .constant(Task()))
}

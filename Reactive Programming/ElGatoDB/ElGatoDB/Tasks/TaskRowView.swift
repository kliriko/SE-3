//
//  TaskRowView.swift
//  ElGatoDB
//
//  Created by Володимир on 12.10.2025.
//

import SwiftUI
import Combine

struct TaskRowView: View {
    var viewModel: TaskListViewModel
    @Binding var task: MyTask
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }

    var body: some View {
        HStack {
            Circle()
                .fill(priorityColor)
                .frame(width: 10, height: 10)

            Button(action: {
                viewModel.taskToggleSubject.send(task)
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
        }
        .swipeActions(edge: .trailing) {
            Button(action: {
                viewModel.taskDeleteSubject.send(task.name)
            }, label: {
                Text("Delete")
            })
            .tint(.red)
        }
        .swipeActions(edge: .leading) {
            Button(action: {
                viewModel.taskEditSubject.send(task)
            }, label: {
                Text("Edit")
            })
            .tint(.blue)
        }
    }
}

#Preview {
    TaskRowView(viewModel: TaskListViewModel(), task: .constant(MyTask(name: "Sample Task", dueDate: Date())))
}

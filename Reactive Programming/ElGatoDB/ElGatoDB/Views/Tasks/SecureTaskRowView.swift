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
                Task { await viewModel.updateTasks() }
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
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task { await viewModel.updateTasks() }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

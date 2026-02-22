//
//  NewSubtaskView.swift
//  ElGatoDB
//
//  Created by Володимир on 06.10.2025.
//
import SwiftUI
import Combine

struct NewSubtaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State var taskName : String = ""
    var parentTaskName: String = ""
    
    init(viewModel: TaskListViewModel, parentTaskName: String) {
        self.viewModel = viewModel
        self.parentTaskName = parentTaskName
    }
    
    var body: some View {
        VStack {
            TextField("Enter subtask name", text: $taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Add subtask") { Task { await viewModel.subtaskCreateSubject.send((name: taskName, in: parentTaskName)) } }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .fontWeight(.bold)
        }
        .padding()
    }
}

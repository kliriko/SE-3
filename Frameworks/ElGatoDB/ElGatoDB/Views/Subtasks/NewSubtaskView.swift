//
//  NewSubtaskView.swift
//  ElGatoDB
//
//  Created by Володимир on 06.10.2025.
//
import SwiftUI

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
            
            Button("Add subtask") {
                do {
                    Task {
                        try viewModel.dataManager.createSubtask(taskName, in: parentTaskName)
                        await viewModel.updateTasks()
                    }
                } catch {
                    print("Failed to add new subtask")
                }
                
                viewModel.presentSubtaskPopup = false
                viewModel.lastTaskName = ""
            }
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

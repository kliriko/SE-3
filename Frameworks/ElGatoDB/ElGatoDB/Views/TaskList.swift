//
//  TaskList.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import SwiftUI

struct TaskList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject private var viewModel = TaskListViewModel(usingRealm: false)
    
    var body: some View {
        NavigationStack {
            VStack{
                List {
                    ForEach($viewModel.tasks) { $task in
                        TaskRowView(viewModel: viewModel, task: task)
                        ForEach(task.subTasks) { subtask in
                            SubtaskRowView(viewModel: viewModel, subtask: subtask, task: $task)
                        }
                    }
                }
            }
        }
        .toolbar() {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.presentTaskPopup = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.notificationCenter.listPendingNotifications()
                }, label: {
                    Image(systemName: "printer.filled.and.paper")
                })
            }
        }
        .navigationTitle("Todo pro max")
        .onAppear {
            viewModel.initContext(context: managedObjectContext)
            viewModel.updateTasks()
        }
        .sheet(isPresented: $viewModel.presentTaskPopup){
            NewTaskView(viewModel: viewModel)
                .presentationDetents([.fraction(0.25)])
        }
        .sheet(isPresented: $viewModel.presentSubtaskPopup){
            NewSubtaskView(viewModel: viewModel, parentTaskName: viewModel.lastTaskName)
                .presentationDetents([.fraction(0.25)])
        }
    }
}

//
//  TaskList.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import SwiftUI

struct TaskList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var viewModel: TaskListViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                List {
                    ForEach($viewModel.tasks.sorted(by: {$0.name.wrappedValue < $1.name.wrappedValue})) { $task in
                        TaskRowView(viewModel: viewModel, task: $task)
                        ForEach(task.subTasks) { subtask in
                            SubtaskRowView(viewModel: viewModel, subtask: subtask, task: $task)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.presentTaskPopup = true}) { Image(systemName: "plus") }
                }
            }
            .navigationTitle("Todo pro max")
            .onAppear { viewModel.initContext(context: managedObjectContext) }
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
}

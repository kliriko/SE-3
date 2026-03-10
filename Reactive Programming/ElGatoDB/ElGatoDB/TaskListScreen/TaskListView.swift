//
//  TaskList.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import SwiftUI
import CoreData

struct TaskList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var viewModel: TaskListViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                List {
                    TextField("Type to search", text: $viewModel.inputFieldText)
                        .padding(15)
                        .glassEffect(.regular)
                        
                    
                    ForEach($viewModel
                        .filteredTasks
                        .sorted(by: {$0.name.wrappedValue < $1.name.wrappedValue})) { $task in
                        TaskRowView(viewModel: viewModel, task: $task)
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
                    .presentationDetents([.fraction(0.35)])
            }
        }
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let context = controller.container.viewContext

    let sampleTasks: [(String, Date?, Bool, String)] = [
        ("Buy groceries", .now.addingTimeInterval(3600), false, "high"),
        ("Walk the cat", .now.addingTimeInterval(7200), false, "low"),
        ("Finish homework", nil, true, "medium"),
    ]
    for (name, date, done, priority) in sampleTasks {
        let task = TodoTask(context: context)
        task.name = name
        task.dueDate = date
        task.isDone = done
        task.priority = priority
    }
    try? context.save()

    return TaskList(viewModel: TaskListViewModel())
        .environment(\.managedObjectContext, context)
}

//
//  NewTaskView.swift
//  ElGatoDB
//
//  Created by Володимир on 03.10.2025.
//

import SwiftUI

struct NewTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State var taskName : String = ""
    @State private var date: Date? = nil
    private var dateForPicker: Binding<Date> {
        Binding<Date>(
            get: { date ?? Date() },
            set: {
                date = $0
            }
        )
    }
    
    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextField("Enter task name", text: $taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Add task") {
                do {
                    try viewModel.manager.createTask(taskName, dueDate: date)
                    viewModel.notificationCenter.scheduleLocalNotification(title: taskName, body: "Your task is due soon", date: date ?? Date())
                    viewModel.updateTasks()
                } catch {
                    print("Failed to add new task")
                }
                
                viewModel.presentTaskPopup = false
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .fontWeight(.bold)
            
            DatePicker(
                    "Deadline",
                    selection: dateForPicker,
                    displayedComponents: [.date, .hourAndMinute]
                )
        }
        .padding()
    }
}

#Preview {
    NewTaskView(viewModel: TaskListViewModel(usingRealm: false))
}

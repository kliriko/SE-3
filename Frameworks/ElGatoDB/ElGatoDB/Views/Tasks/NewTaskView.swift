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
    @State private var isProtected: Bool = false
    private var authManager = AuthManager()
    
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
            
            HStack {
                Button("Add task") {
                    if(isProtected) {
                        try! authManager.addProtectedTask(MyTask(name: taskName, dueDate: date))
                    } else {
                        do {
                            try viewModel.dataManager.createTask(taskName, dueDate: date)
                        } catch {
                            print("Failed to add new task")
                        }
                    }
                    Task {
                        await viewModel.updateTasks()
                    }
                    viewModel.notificationManager.scheduleLocalNotification(title: taskName, body: "Your task is due soon", date: date ?? Date())
                    viewModel.presentTaskPopup = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .fontWeight(.bold)
                
                Button(action: {
                    isProtected.toggle()
                }, label: {
                    Image(systemName: isProtected ? "shield.fill" : "shield")
                })
                .buttonStyle(.plain)
            }
            
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

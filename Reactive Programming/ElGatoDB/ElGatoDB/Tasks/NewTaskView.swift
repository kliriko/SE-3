//
//  TaskFormView.swift
//  ElGatoDB
//
//  Created by Володимир on 03.10.2025.
//

import SwiftUI
import Combine
import CoreData

struct TaskFormView: View {
    @ObservedObject var viewModel: TaskFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var dateForPicker: Binding<Date> {
        Binding<Date>(
            get: { viewModel.date ?? Date() },
            set: { viewModel.date = $0 }
        )
    }
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .font(.headline)
                .padding(.top)
            
            TextField("Enter task name", text: $viewModel.taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button(viewModel.buttonLabel) {
                    viewModel.saveSubject.send()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .fontWeight(.bold)
            }
            
            DatePicker(
                    "Deadline",
                    selection: dateForPicker,
                    displayedComponents: [.date, .hourAndMinute]
                )
            
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(TaskPriority.allCases, id: \.self) { p in
                    Text(p.label).tag(p)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .onReceive(viewModel.didSave) { _ in
            dismiss()
        }
    }
}

#Preview {
    TaskFormView(viewModel: TaskFormViewModel(dataManager: CoreDataManager(PersistenceController(inMemory: true).container.viewContext)))
}

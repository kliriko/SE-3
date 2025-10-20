//
//  IncomingMessageView.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import SwiftUI

struct NotificationRowView: View {
    @ObservedObject var taskViewModel: TaskListViewModel
    @ObservedObject var inboxViewModel: InboxViewModel
    @Binding var message: IncomingNotification
    
    var body: some View {
        HStack {
            Text(message.task.name)
            Spacer()
            if message.status == .pending {
                Button(action: {
                    inboxViewModel.updateNotification(title: message.title, isAccepted: true)
                    inboxViewModel.fetchNotifications()
                    
                    try! taskViewModel.dataManager.createTask(message.task.name, dueDate: message.task.date)
                    taskViewModel.notificationCenter.scheduleLocalNotification(title: message.task.name, body: "", date: message.task.date!)
                    Task {
                        await taskViewModel.updateTasks()
                    }
                }, label: {
                    Image(systemName: "checkmark")
                })
                .buttonStyle(.plain)
                .tint(.green)
                
                Button(action: {
                    inboxViewModel.updateNotification(title: message.title, isAccepted: false)
                    inboxViewModel.fetchNotifications()
                }, label: {
                    Image(systemName: "xmark")
                })
                .buttonStyle(.plain)
                .tint(.red)
            }
        }
        .background(message.status == .accepted ? Color.green.opacity(0.3) : Color.clear)
        .background(message.status == .declined ? Color.red.opacity(0.3) : Color.clear)
    }
}

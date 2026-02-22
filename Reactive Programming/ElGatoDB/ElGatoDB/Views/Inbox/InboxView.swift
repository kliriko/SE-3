//
//  InboxView.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import SwiftUI
import NotificationCenter

struct InboxView: View {
    @ObservedObject var inboxViewModel: InboxViewModel
    @ObservedObject var taskViewModel: TaskListViewModel
    
    var body: some View {
        List {
            ForEach($inboxViewModel.incomingNotifications) { $notification in
                NotificationRowView(taskViewModel: taskViewModel, inboxViewModel: inboxViewModel, message: $notification)
            }
        }
        .onAppear {
            inboxViewModel.fetchNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("la policia"))) {_ in
            inboxViewModel.fetchNotifications()
        }
    }
}

//
//  InboxView.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import SwiftUI

struct InboxView: View {
    var inboxViewModel: InboxViewModel
    var taskViewModel: TaskListViewModel
    
    var body: some View {
        List {
            ForEach (inboxViewModel.incomingNotifications) { notification in
                NotificationRowView(taskViewModel: taskViewModel, message: notification)
            }
        }
        .onChange(of: inboxViewModel.notifications.count) {
            inboxViewModel.update(with: Array(inboxViewModel.notifications))
        }
    }
}

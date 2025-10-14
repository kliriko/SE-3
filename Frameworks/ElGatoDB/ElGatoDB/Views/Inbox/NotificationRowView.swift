//
//  IncomingMessageView.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import SwiftUI

struct NotificationRowView: View {
    var taskViewModel: TaskListViewModel
    @State var message: IncomingNotification
    @State var color: Color?
    
    var body: some View {
        HStack {
            Text(message.task.name)
            Spacer()
            if message.status == .pending {
                Button(action: {
                    message.status = .accepted
                    color = .green
                }, label: {
                    Image(systemName: "checkmark")
                })
                .tint(.green)
                
                Button(action: {
                    message.status = .declined
                    color = .red
                }, label: {
                    Image(systemName: "xmark")
                })
                .tint(.red)
            }
        }
        .background(color.opacity(0.3))
    }
}

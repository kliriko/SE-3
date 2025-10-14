//
//  ContentView.swift
//  ElGatoDB
//
//  Created by Володимир on 01.10.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var taskListViewModel: TaskListViewModel = TaskListViewModel(usingRealm: false)
    @StateObject var inboxViewModel: InboxViewModel = InboxViewModel()
    var body: some View {
        TabView {
            NavigationView {
                TaskList(viewModel: taskListViewModel)
            }
            .tabItem {
                Label("Tasks", systemImage: "list.number")
            }
            
            InboxView(inboxViewModel: inboxViewModel, taskViewModel: taskListViewModel)
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }
        }
        
    }
}

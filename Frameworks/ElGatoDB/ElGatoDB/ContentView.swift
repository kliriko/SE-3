//
//  ContentView.swift
//  ElGatoDB
//
//  Created by Володимир on 01.10.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var taskListViewModel: TaskListViewModel = TaskListViewModel(usingRealm: false)
    @StateObject var inboxViewModel: InboxViewModel = InboxViewModel()
    
    @ObservedObject var authManager: AuthManager = AuthManager()
    @State private var didLogin: Bool = false
    
    var body: some View {
        if didLogin {
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
            .onAppear {
                inboxViewModel.initContext(context: managedObjectContext)
            }
        } else {
            LoginView(isLoggedIn: $didLogin)
                .task {
                    do {
                        let credentials = try authManager.getAllKeychainCredentials()
                        if !credentials.isEmpty {
                                didLogin = await authManager.tryServerLogin(username: credentials[0].username, password: credentials[0].password)
                        }
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

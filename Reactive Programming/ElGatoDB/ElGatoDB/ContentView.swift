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
    @StateObject var taskListViewModel: TaskListViewModel = TaskListViewModel()
    
    var body: some View {
            TabView {
                NavigationView { TaskList(viewModel: taskListViewModel) }
                .tabItem { Label("Tasks", systemImage: "list.number") }
            }
    }
}

//
//  ContentView.swift
//  ElGatoDB
//
//  Created by Володимир on 01.10.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            TaskList()
                .onAppear() {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("Permission granted")
                        } else if let error = error {
                            print("Permission denied: \(error)")
                        }
                    }
                }
        }
    }
}

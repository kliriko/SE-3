//
//  test_appApp.swift
//  test app
//
//  Created by Володимир on 25.09.2025.
//

import SwiftUI
import QKnobs

@main
struct test_appApp: App {
    var body: some Scene {
        WindowGroup {
            QFader()
                .frame(width: 50, height: 200)
        }
    }
}

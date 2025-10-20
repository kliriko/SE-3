//
//  LoginView.swift
//  ElGatoDB
//
//  Created by Володимир on 20.10.2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager: AuthManager = AuthManager()
    @State var username: String = ""
    @State var password: String = ""
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 20){
                TextField("Username", text: $username)
                    .textContentType(.username)
                    
                TextField("Password", text: $password)
                    .textContentType(.password)
                
                Button("Login", action: {
                    Task {
                        if await authManager.tryServerLogin(username: username, password: password) {
                            do {
                                try authManager.saveToKeychain(account: username, password: password)
                                isLoggedIn = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                })

            }
            .padding(.horizontal, 40)
        }
    }
}

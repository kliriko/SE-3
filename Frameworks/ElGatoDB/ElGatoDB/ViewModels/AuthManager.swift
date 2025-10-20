//
//  AuthManager.swift
//  ElGatoDB
//
//  Created by Володимир on 20.10.2025.
//

import Foundation
import Combine
import LocalAuthentication

enum KeychainError: Error {
    case itemNotFound
    case unexpectedStatus(OSStatus)
    case invalidData
}

class AuthManager: ObservableObject {
    let service = "ElGatoDB"
    
    func getKeychainCredentials(account: String) throws -> String {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let existingItem = itemCopy as? Data,
              let password = String(data: existingItem, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return password
    }
    
    func saveToKeychain(account: String, password: String) throws {
        let passwordData = password.data(using: .utf8)!
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject
        ]
        let attributes: [String: AnyObject] = [
            kSecValueData as String: passwordData as AnyObject
        ]
        let status = SecItemAdd(query.merging(attributes) { (_, new) in new } as CFDictionary, nil)
        if status == errSecDuplicateItem {
            // Update if already exists
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func getAllKeychainCredentials() throws -> [(username: String, password: String)] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        guard let items = result as? [[String: Any]] else { throw KeychainError.invalidData }
        var credentials: [(username: String, password: String)] = []
        for item in items {
            guard let username = item[kSecAttrAccount as String] as? String,
                  let passwordData = item[kSecValueData as String] as? Data,
                  let password = String(data: passwordData, encoding: .utf8) else {
                throw KeychainError.invalidData
            }
            credentials.append((username: username, password: password))
        }
        print(credentials)
        return credentials
    }
    
    func tryServerLogin(username: String, password: String) async -> Bool {
        let url = URL(string: "http://localhost:8080/auth")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let credentials = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: credentials)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var response: URLResponse
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            return false
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            return false
        }
        print("HTTP status:", httpResponse.statusCode)
        return httpResponse.statusCode == 200
    }
    
    private let protectedTasksAccount = "ProtectedTasks"

    func getProtectedTasks() async -> [MyTask] {
        do {
            let base64String = try getKeychainCredentials(account: protectedTasksAccount)
            guard let data = Data(base64Encoded: base64String) else { return [] }
            return try JSONDecoder().decode([MyTask].self, from: data)
        } catch KeychainError.itemNotFound {
            return []
        } catch {
            print("Keychain getProtectedTasks error:", error)
            return []
        }
    }

//    func addProtectedTask(_ task: MyTask) throws {
//        var tasks = try awaitSafeGetProtectedTasks()
//        
//        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//            tasks[index] = task
//        } else {
//            tasks.append(task)
//        }
//
//        try saveTasksToKeychain(tasks)
//    }
    
    func addProtectedTask(_ task: MyTask) throws {
        var tasks = try awaitSafeGetProtectedTasks()
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            print("✅ Updated existing task: \(task.name)")
        } else {
            tasks.append(task)
            print("🆕 Added new task: \(task.name)")
        }
        
        try saveTasksToKeychain(tasks)
    }


    func deleteProtectedTask(id: String) throws {
        var tasks = try awaitSafeGetProtectedTasks()
        tasks.removeAll { $0.id == id }
        try saveTasksToKeychain(tasks)
    }

    func deleteAllProtectedTasks() throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: protectedTasksAccount as AnyObject
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Private Helpers
    func awaitSafeGetProtectedTasks() throws -> [MyTask] {
        do {
            let base64String = try getKeychainCredentials(account: protectedTasksAccount)
            guard let data = Data(base64Encoded: base64String) else { return [] }
            return try JSONDecoder().decode([MyTask].self, from: data)
        } catch KeychainError.itemNotFound {
            return []
        } catch {
            throw error
        }
    }

    private func saveTasksToKeychain(_ tasks: [MyTask]) throws {
        let data = try JSONEncoder().encode(tasks)
        let base64 = data.base64EncodedString()
        try saveToKeychain(account: protectedTasksAccount, password: base64)
    }
    
    func localAuth() async -> Bool {
        var context = LAContext()
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            return false
        }
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account")
            print("authorized")
            return true
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
}

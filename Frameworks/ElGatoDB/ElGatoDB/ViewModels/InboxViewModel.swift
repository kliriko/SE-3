//
//  InboxViewModel.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class InboxViewModel: ObservableObject {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Published var incomingNotifications: [IncomingNotification] = []
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Notification.dueDate, ascending: true)], animation: .default)
    var notifications: FetchedResults<Notification>
    
    func update(with notifications: [Notification]) {
        self.incomingNotifications = notifications.map { IncomingNotification($0) }
    }
    
    func fetchNotifications() {
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        incomingNotifications = try! managedObjectContext.fetch(fetchRequest).map { IncomingNotification($0) }
    }
    
    func updateNotification(name: String, isAccepted: Bool) {
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        guard let notification = try! managedObjectContext.fetch(fetchRequest).first else {
            print("Failed to fetch notification with name \(name)")
            return
        }
        
        notification.status = isAccepted ? "accepted" : "declined"
        try! managedObjectContext.save()
    }
}

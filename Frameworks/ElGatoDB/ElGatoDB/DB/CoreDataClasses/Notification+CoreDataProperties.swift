//
//  Notification+CoreDataProperties.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//
//

public import Foundation
public import CoreData


public typealias NotificationCoreDataPropertiesSet = NSSet

extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification")
    }

    @NSManaged public var title: String
    @NSManaged public var dueDate: Date
    @NSManaged public var status: String
}

extension Notification : Identifiable {

}

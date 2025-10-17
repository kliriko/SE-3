//
//  MyNotification+CoreDataProperties.swift
//  ElGatoDB
//
//  Created by Володимир on 15.10.2025.
//
//

public import Foundation
public import CoreData


public typealias MyNotificationCoreDataPropertiesSet = NSSet

extension MyNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyNotification> {
        return NSFetchRequest<MyNotification>(entityName: "MyNotification")
    }

    @NSManaged public var dueDate: Date
    @NSManaged public var status: String
    @NSManaged public var title: String

}

extension MyNotification : Identifiable {

}

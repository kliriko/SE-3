//
//  TodoTask+CoreDataProperties.swift
//  ElGatoDB
//
//  Created by Володимир on 15.10.2025.
//
//

public import Foundation
public import CoreData


public typealias TodoTaskCoreDataPropertiesSet = NSSet

extension TodoTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTask> {
        return NSFetchRequest<TodoTask>(entityName: "TodoTask")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var name: String
    @NSManaged public var priority: String?

}

extension TodoTask : Identifiable {

}

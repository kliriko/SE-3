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
    @NSManaged public var notify: Bool
    @NSManaged public var subTasks: NSSet?

}

// MARK: Generated accessors for subTasks
extension TodoTask {

    @objc(addSubTasksObject:)
    @NSManaged public func addToSubTasks(_ value: TodoSubtask)

    @objc(removeSubTasksObject:)
    @NSManaged public func removeFromSubTasks(_ value: TodoSubtask)

    @objc(addSubTasks:)
    @NSManaged public func addToSubTasks(_ values: NSSet)

    @objc(removeSubTasks:)
    @NSManaged public func removeFromSubTasks(_ values: NSSet)

}

extension TodoTask : Identifiable {

}

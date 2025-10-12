//
//  TodoSubtask+CoreDataProperties.swift
//  ElGatoDB
//
//  Created by Володимир on 11.10.2025.
//
//

public import Foundation
public import CoreData


public typealias TodoSubtaskCoreDataPropertiesSet = NSSet

extension TodoSubtask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoSubtask> {
        return NSFetchRequest<TodoSubtask>(entityName: "TodoSubtask")
    }

    @NSManaged public var isDone: Bool
    @NSManaged public var name: String
    @NSManaged public var notify: Bool
    @NSManaged public var task: TodoTask?

}

extension TodoSubtask : Identifiable {

}

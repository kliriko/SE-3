//
//  RealmCoreBridge.swift
//  ElGatoDB
//
//  Created by Володимир on 02.10.2025.
//

import Foundation
import CoreData
import SwiftUI

enum DrumNDataBaseError: Error {
    case TaskAlreadyExists (name: String), TaskNotFound (name: String), SubTaskNotFound(name: String, in: String),
         InvalidFieldType(field: String), FailedToDelete(name: String), SubtaskAlreadyExists(name: String, in: String), FailedToCreateSubtask(name: String, in: String)
}

protocol DrumNDataBase {
    func createTask (_ name: String, dueDate: Date?) throws
    
    func getTask (_ name: String) throws -> MyTask
    
    func updateTask<rowType> (_ name: String, key: String, value: rowType) throws
    
    func deleteTask (_ name: String) throws
    
    func createSubtask (_ name: String, in taskName: String) throws
    
    func getSubtask (_ name: String, in taskName: String) throws -> SubTask
    
    func updateSubtask<rowType> (_ name: String, in taskName: String, key: String, value: rowType) throws
    
    func deleteSubtask (_ name: String, in taskName: String) throws
    
    func getAllTasks() -> [MyTask]
}

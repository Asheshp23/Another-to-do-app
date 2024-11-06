//
//  ToDoListItemEntity+CoreDataProperties.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-05.
//
//

import Foundation
import CoreData


extension ToDoListItemEntity {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItemEntity> {
    return NSFetchRequest<ToDoListItemEntity>(entityName: "ToDoListItemEntity")
  }
  
  @NSManaged public var id: UUID
  @NSManaged public var title: String
  @NSManaged public var isCompleted: Bool
  @NSManaged public var createdDate: Date?
  @NSManaged public var dueDate: Date?
  @NSManaged public var priority: Int16
  
}

extension ToDoListItemEntity : Identifiable {
  
}

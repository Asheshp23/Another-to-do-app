//
//  CoreDataStackProtocol.swift
//  FieldOpsClone
//
//  Created by Ashesh Patel on 2024-11-18.
//
import Foundation
import CoreData
import Combine

protocol CoreDataStackProtocol {
  var viewContext: NSManagedObjectContext { get }
  func saveContext()
}

final class CoreDataStack: CoreDataStackProtocol, Sendable {
  let persistentContainer: NSPersistentContainer
  
  init() {
    persistentContainer = NSPersistentContainer(name: "ToDoListCoreDataModel")
    
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("ToDoListCoreDataModel.sqlite")
    print(url?.path() ?? "no path")
    // Configure the persistent store
    let description = NSPersistentStoreDescription(url: url!)
    persistentContainer.persistentStoreDescriptions = [description]
    
    persistentContainer.loadPersistentStores { storeDescription, error in
      if let error = error {
        fatalError("Unresolved error \(error)")
      }
    }
    
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
  }
  
  var viewContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  func saveContext() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}

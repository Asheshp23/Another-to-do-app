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

class CoreDataStack: CoreDataStackProtocol {
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "ToDoListCoreDataModel")
    
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("ToDoListCoreDataModel.sqlite")
    print(url?.path() ?? "no path")
    // Configure the persistent store
    let description = NSPersistentStoreDescription(url: url!)
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error {
        fatalError("Unresolved error \(error)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()
  
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

//
//  CoreDataManager.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import CoreData
import Combine

protocol CoreDataManagerProtocol {
  var viewContext: NSManagedObjectContext { get }
  var objectWillChange: AnyPublisher<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> { get }
  func saveContext()
  func fetch<T: NSManagedObject>(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]
  func fetchById<T: NSManagedObject>(id: UUID) throws -> T?
}

class CoreDataManager: ObservableObject, CoreDataManagerProtocol {
  static let shared = CoreDataManager()
  
  private let stack: CoreDataStack = CoreDataStack()
  private let observer: CoreDataObserverProtocol
  
  var viewContext: NSManagedObjectContext {
    return stack.viewContext
  }
  
  init(observer: CoreDataObserverProtocol? = nil) {
    self.observer = observer ?? CoreDataObserver(context: stack.viewContext)
  }
  
  var objectWillChange: AnyPublisher<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> {
    return observer.objectWillChange.eraseToAnyPublisher()
  }
  
  func saveContext() {
    stack.saveContext()
  }
  
  func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
    let entityName = String(describing: T.self)
    let request = NSFetchRequest<T>(entityName: entityName)
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    
    do {
      return try stack.viewContext.fetch(request)
    } catch {
      print("Error fetching \(entityName): \(error)")
      return []
    }
  }
  
  func fetchById<T: NSManagedObject>(id: UUID) throws -> T? {
    let entityName = String(describing: T.self)
    let request = NSFetchRequest<T>(entityName: entityName)
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    
    do {
      let result = try stack.viewContext.fetch(request)
      return result.first
    } catch {
      print("Error fetching \(entityName) by id \(id): \(error)")
      throw error
    }
  }
}

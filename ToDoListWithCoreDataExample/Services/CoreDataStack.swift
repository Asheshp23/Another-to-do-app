import Foundation
import CoreData
import Combine

protocol CoreDataStackProtocol {
  var viewContext: NSManagedObjectContext { get }
  func saveContext()
}

protocol CoreDataObserverProtocol {
  var objectWillChange: PassthroughSubject<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> { get }
}

protocol CoreDataManagerProtocol {
  var viewContext: NSManagedObjectContext { get }
  var objectWillChange: AnyPublisher<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> { get }
  func saveContext()
  func fetch<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]
}

// 1. Core Data Stack
class CoreDataStack: CoreDataStackProtocol {
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "ToDoListCoreDataModel")
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
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

// 2. Core Data Observer
class CoreDataObserver: NSObject, CoreDataObserverProtocol {
  let objectWillChange = PassthroughSubject<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never>()
  
  private let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
    super.init()
    setupNotificationObservers()
  }
  
  private func setupNotificationObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(managedObjectContextObjectsDidChange),
      name: NSManagedObjectContext.didChangeObjectsNotification,
      object: context
    )
  }
  
  @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    
    let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
    let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
    let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
    
    objectWillChange.send((inserted: inserted, updated: updated, deleted: deleted))
  }
}

// 3. Core Data Manager
class CoreDataManager: ObservableObject, CoreDataManagerProtocol {
  private let stack: CoreDataStackProtocol
  private let observer: CoreDataObserverProtocol
  
  var viewContext: NSManagedObjectContext {
    return stack.viewContext
  }
  
  init(stack: CoreDataStackProtocol, observer: CoreDataObserverProtocol? = nil) {
    self.stack = stack
    self.observer = observer ?? CoreDataObserver(context: stack.viewContext)
  }
  
  var objectWillChange: AnyPublisher<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> {
    return observer.objectWillChange.eraseToAnyPublisher()
  }
  
  func saveContext() {
    stack.saveContext()
  }
  
  func fetch<T: NSManagedObject>(_ entityType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
    let request = NSFetchRequest<T>(entityName: String(describing: entityType))
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    
    do {
      return try stack.viewContext.fetch(request)
    } catch {
      print("Error fetching \(entityType): \(error)")
      return []
    }
  }
}

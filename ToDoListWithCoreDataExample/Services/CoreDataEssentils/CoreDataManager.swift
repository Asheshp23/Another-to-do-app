import Foundation
import Combine
import CoreData
import os.log

protocol PersistenceControlling {
  var container: NSPersistentContainer { get }
}

final class CoreDataManager {
  // MARK: - Private Properties
  private let stack: PersistenceControlling
  private let logger: Logger
  private let operationQueue: OperationQueue
  
  // MARK: - Context Management
  var viewContext: NSManagedObjectContext {
    stack.container.viewContext
  }
  
  private lazy var backgroundContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = viewContext
    return context
  }()
  
  // MARK: - Combine Publisher
  var objectChangesPublisher: AnyPublisher<CoreDataChanges, Never> {
    NotificationCenter.default
      .publisher(for: .NSManagedObjectContextObjectsDidChange, object: stack.container.viewContext)
      .map { notification -> CoreDataChanges in
        let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
        let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
        let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
        return CoreDataChanges(inserted: inserted, updated: updated, deleted: deleted)
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  // MARK: - Initialization
  init(
    stack: PersistenceControlling,
    logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CoreDataManager")
  ) {
    self.stack = stack
    self.logger = logger
    
    // Configure operation queue for background processing
    self.operationQueue = OperationQueue()
    self.operationQueue.maxConcurrentOperationCount = 2
    self.operationQueue.qualityOfService = .userInitiated
    
    // Setup notification observers
    setupContextDidSaveNotificationObserver()
  }
  
  // MARK: - Context Save Methods
  func saveContext(context: NSManagedObjectContext? = nil) throws {
    let contextToSave = context ?? viewContext
    
    try contextToSave.performAndWait {
      guard contextToSave.hasChanges else { return }
      
      do {
        try contextToSave.save()
        logger.info("Context saved successfully")
      } catch {
        logger.error("Context save failed: \(error.localizedDescription)")
        throw CoreDataManagerError.saveError(underlyingError: error)
      }
    }
  }
  
  // MARK: - Fetching Methods
  func fetch<T: NSManagedObject>(
    predicate: NSPredicate? = nil,
    sortDescriptors: [NSSortDescriptor]? = nil,
    fetchLimit: Int? = nil,
    in context: NSManagedObjectContext? = nil
  ) throws -> [T] {
    let contextToUse = context ?? viewContext
    var results: [T] = []
    let entityName = String(describing: T.self)
    
    try contextToUse.performAndWait {
      let request = NSFetchRequest<T>(entityName: entityName)
      request.predicate = predicate
      request.sortDescriptors = sortDescriptors
      request.fetchLimit = fetchLimit ?? 0
      
      do {
        results = try contextToUse.fetch(request)
        logger.debug("Fetched \(results.count) \(entityName) objects")
      } catch {
        logger.error("Fetch failed for \(entityName): \(error.localizedDescription)")
        throw CoreDataManagerError.fetchError(entity: entityName, underlyingError: error)
      }
    }
    
    return results
  }
  
  func fetchById<T: NSManagedObject>(id: UUID, in context: NSManagedObjectContext? = nil) async throws -> T {
    let contextToUse = context ?? viewContext
    let entityName = String(describing: T.self)
    return try await contextToUse.perform {
      do {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        if let result = try contextToUse.fetch(request).first {
          // Ensure the object is accessed only on the same context's thread
          return result
        } else {
          throw CoreDataManagerError.objectNotFound(entity: entityName, id: id)
        }
      } catch {
        throw CoreDataManagerError.fetchError(entity: entityName, underlyingError: error)
      }
    }
  }
  
  
  // MARK: - Batch Operations
  func batchUpdate<T: NSManagedObject>(
    predicate: NSPredicate? = nil,
    update: @escaping (T) -> Void
  ) throws {
    let entityName = String(describing: T.self)
    
    try backgroundContext.performAndWait {
      let fetchRequest = NSFetchRequest<T>(entityName: entityName)
      fetchRequest.predicate = predicate
      
      do {
        let objectsToUpdate = try backgroundContext.fetch(fetchRequest)
        objectsToUpdate.forEach(update)
        try self.saveContext(context: backgroundContext)
        
        logger.info("Batch updated \(objectsToUpdate.count) \(entityName) objects")
      } catch {
        logger.error("Batch update failed for \(entityName): \(error.localizedDescription)")
        throw CoreDataManagerError.batchUpdateError(entity: entityName, underlyingError: error)
      }
    }
  }
  
  // MARK: - Notification Observers
  private func setupContextDidSaveNotificationObserver() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contextDidSave),
      name: .NSManagedObjectContextDidSave,
      object: nil
    )
  }
  
  @objc private func contextDidSave(_ notification: Notification) {
    guard let context = notification.object as? NSManagedObjectContext,
          context != viewContext else { return }
    
    viewContext.perform {
      self.viewContext.mergeChanges(fromContextDidSave: notification)
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Error Handling
enum CoreDataManagerError: Error, LocalizedError {
  case objectNotFound(entity: String, id: UUID)
  case fetchError(entity: String, underlyingError: Error)
  case saveError(underlyingError: Error)
  case batchUpdateError(entity: String, underlyingError: Error)
  
  var errorDescription: String? {
    switch self {
    case .objectNotFound(let entity, let id):
      return "Entity \(entity) with ID \(id) not found."
    case .fetchError(let entity, let underlyingError):
      return "Fetch error for \(entity): \(underlyingError.localizedDescription)"
    case .saveError(let underlyingError):
      return "Save failed: \(underlyingError.localizedDescription)"
    case .batchUpdateError(let entity, let underlyingError):
      return "Batch update failed for \(entity): \(underlyingError.localizedDescription)"
    }
  }
}

// MARK: - Changes Tracking
struct CoreDataChanges {
  let inserted: Set<NSManagedObject>
  let updated: Set<NSManagedObject>
  let deleted: Set<NSManagedObject>
}

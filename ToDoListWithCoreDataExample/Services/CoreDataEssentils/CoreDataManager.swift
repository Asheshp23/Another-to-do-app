import CoreData
import Combine

protocol CoreDataManagerProtocol {
  var viewContext: NSManagedObjectContext { get }
  var objectWillChange: AnyPublisher<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> { get }
  func saveContext()
  func fetch<T: NSManagedObject>(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]
  func fetchById<T: NSManagedObject>(id: UUID) async throws -> T?
}

@MainActor
final class CoreDataManager: @preconcurrency ObservableObject, @preconcurrency CoreDataManagerProtocol {
  @MainActor static let shared = CoreDataManager()
  
  private let stack: CoreDataStack = CoreDataStack()
  private let observer: CoreDataObserverProtocol
  
  var viewContext: NSManagedObjectContext {
    stack.viewContext
  }
  
  init(observer: CoreDataObserverProtocol? = nil) {
    self.observer = observer ?? CoreDataObserver(context: stack.viewContext)
  }
  
  var objectWillChange: AnyPublisher<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> {
    observer.objectWillChange.eraseToAnyPublisher()
  }
  
  func saveContext() {
    stack.viewContext.perform { [weak self] in
      guard let self = self else { return }
      do {
        if self.stack.viewContext.hasChanges {
          try self.stack.viewContext.save()
        }
      } catch {
        print("Error saving context: \(error)")
      }
    }
  }
  
  func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
    var results: [T] = []
    let entityName = String(describing: T.self)
    
    stack.viewContext.performAndWait {
      let request = NSFetchRequest<T>(entityName: entityName)
      request.predicate = predicate
      request.sortDescriptors = sortDescriptors
      
      do {
        results = try stack.viewContext.fetch(request)
      } catch {
        print("Error fetching \(entityName): \(error)")
      }
    }
    
    return results
  }
  
  func fetchById<T: NSManagedObject>(id: UUID) async throws -> T? {
    stack.viewContext.performAndWait {
      let entityName = String(describing: T.self)
      let request = NSFetchRequest<T>(entityName: entityName)
      request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
      request.fetchLimit = 1
      do {
        // Fetch result
        guard let result = try self.stack.viewContext.fetch(request).first else {
          return nil // No result found
        }
        return result
        // Convert the object into a fault-safe detached object or simply return the object safely
        
      } catch {
        print("Error fetching \(entityName) by id \(id): \(error)")
        return nil
      }
    }
  }
}

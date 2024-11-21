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
  
  func fetchById<T: NSManagedObject>(_ entityType: T.Type, id: UUID) throws -> T? {
    let request = NSFetchRequest<T>(entityName: String(describing: entityType))
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    
    do {
      let result = try stack.viewContext.fetch(request)
      return result.first
    } catch {
      print("Error fetching \(entityType) by id \(id): \(error)")
      throw error
    }
  }
}

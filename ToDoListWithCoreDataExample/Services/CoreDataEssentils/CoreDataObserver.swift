import CoreData
import Combine

protocol CoreDataObserverProtocol {
  var objectWillChange: PassthroughSubject<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never> { get }
}

final class CoreDataObserver: CoreDataObserverProtocol {
  let objectWillChange = PassthroughSubject<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never>()
  
  private let context: NSManagedObjectContext
  private var cancellables: Set<AnyCancellable> = []
  private let lockQueue = DispatchQueue(label: "CoreDataObserver.LockQueue", attributes: .concurrent)
  
  init(context: NSManagedObjectContext) {
    self.context = context
    observeContextChanges()
  }
  
  private func observeContextChanges() {
    NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
      .compactMap { notification -> (inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>)? in
        guard let userInfo = notification.userInfo else { return nil }
        let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? Set()
        let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set()
        let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? Set()
        return (inserted: inserted, updated: updated, deleted: deleted)
      }
      .receive(on: lockQueue)
      .sink { [weak self] changes in
        self?.objectWillChange.send(changes)
      }
      .store(in: &cancellables)
  }
}

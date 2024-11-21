class CoreDataObserver: NSObject, CoreDataObserverProtocol {
  let objectWillChange = PassthroughSubject<(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>), Never>()
  
  let context: NSManagedObjectContext
  
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
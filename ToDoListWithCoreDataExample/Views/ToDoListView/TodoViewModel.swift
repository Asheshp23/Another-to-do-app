//
//  TodoViewModel.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-05.
//
import Combine
import SwiftUI
import CoreData

final class TodoViewModel: ObservableObject {
  @Published private(set) var tasks: [ToDoListItemEntity] = []
  
  private let coreDataManager: CoreDataManager = CoreDataManager(stack: PersistenceController())
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    fetchInitialTasks()
    setupCoreDataObservation()
  }
  
  /// Fetches tasks from Core Data on initialization
  private func fetchInitialTasks() {
    do {
      let sortDescriptor = NSSortDescriptor(keyPath: \ToDoListItemEntity.dueDate, ascending: true)
      let fetchedTasks: [ToDoListItemEntity] = try coreDataManager.fetch(
        predicate: nil,
        sortDescriptors: [sortDescriptor]
      )
      tasks = fetchedTasks
    } catch {
      print("Failed to fetch initial tasks: \(error.localizedDescription)")
    }
  }
 
  /// Observes Core Data changes and updates the tasks array
  private func setupCoreDataObservation() {
    NotificationCenter.default
      .publisher(for: .NSManagedObjectContextObjectsDidChange, object: coreDataManager.viewContext)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] notification in
        guard let self = self else { return }
        self.handleCoreDataChanges(notification: notification)
      }
      .store(in: &cancellables)
  }
  
  /// Handles changes in Core Data
  private func handleCoreDataChanges(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    
    let insertedTasks = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
    let updatedTasks = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
    let deletedTasks = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
    
    // Filter changes for ToDoListItemEntity only
    let inserted = insertedTasks.compactMap { $0 as? ToDoListItemEntity }
    let updated = updatedTasks.compactMap { $0 as? ToDoListItemEntity }
    let deletedIDs = deletedTasks.compactMap { ($0 as? ToDoListItemEntity)?.id }
    
    // Update tasks list
    var currentTasks = tasks
    currentTasks.removeAll { task in deletedIDs.contains(task.id) }
    currentTasks += inserted
    
    for task in updated {
      if let index = currentTasks.firstIndex(where: { $0.id == task.id }) {
        currentTasks[index] = task
      }
    }
    
    // Sort tasks and update published property
    tasks = currentTasks.sorted { ($0.dueDate ?? Date.distantPast) < ($1.dueDate ?? Date.distantPast) }
  }
  
  /// Adds a new task
  @MainActor
  func addTask(title: String, priority: Int16, dueDate: Date) {
    do {
      let task = ToDoListItemEntity(context: coreDataManager.viewContext)
      task.id = UUID()
      task.title = title
      task.priority = priority
      task.dueDate = dueDate
      task.isCompleted = false
      try coreDataManager.saveContext()
    } catch {
      print("Failed to add task: \(error.localizedDescription)")
    }
  }
  
  /// Updates a task's title
  @MainActor
  func updateTaskTitle(_ task: ToDoListItemEntity, newTitle: String) {
    do {
      task.title = newTitle
      try coreDataManager.saveContext()
    } catch {
      print("Failed to update task title: \(error.localizedDescription)")
    }
  }
  
  /// Toggles a task's completion status
  @MainActor
  func toggleTaskCompletion(_ task: ToDoListItemEntity) {
    do {
      task.isCompleted.toggle()
      try coreDataManager.saveContext()
    } catch {
      print("Failed to toggle task completion: \(error.localizedDescription)")
    }
  }
  
  /// Deletes a task
  @MainActor
  func deleteTask(_ task: ToDoListItemEntity) {
    do {
      coreDataManager.viewContext.delete(task)
      try coreDataManager.saveContext()
    } catch {
      print("Failed to delete task: \(error.localizedDescription)")
    }
  }
}

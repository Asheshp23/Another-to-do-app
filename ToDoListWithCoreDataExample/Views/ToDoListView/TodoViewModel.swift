//
//  TodoViewModel.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-05.
//
import Foundation
import Combine
import CoreData

@MainActor
class TodoViewModel: ObservableObject {
  @Published var tasks: [ToDoListItemEntity] = []
  private let coreDataManager = CoreDataManager.shared
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    Task {
      fetchTasks()
      setupSubscriptions()
    }
  }
  
  @MainActor
  private func setupSubscriptions() {
    coreDataManager.objectWillChange
      .receive(on: DispatchQueue.main)
      .sink { [weak self] changes in
        self?.handleCoreDataChanges(inserted: changes.inserted, updated: changes.updated, deleted: changes.deleted)
      }
      .store(in: &cancellables)
  }
  
  private func handleCoreDataChanges(inserted: Set<NSManagedObject>, updated: Set<NSManagedObject>, deleted: Set<NSManagedObject>) {
    // Handle inserted tasks
    for case let task as ToDoListItemEntity in inserted {
      tasks.append(task)
    }
    
    // Handle updated tasks
    for case let task as ToDoListItemEntity in updated {
      if let index = tasks.firstIndex(where: { $0.id == task.id }) {
        tasks[index] = task
      }
    }
    
    // Handle deleted tasks
    for case let task as ToDoListItemEntity in deleted {
      tasks.removeAll { $0.id == task.id }
    }
    
    // Sort tasks if needed
    tasks.sort { $0.dueDate ?? Date() < $1.dueDate ?? Date() }
  }
  
  @MainActor private func fetchTasks() {
    let sortDescriptor = NSSortDescriptor(keyPath: \ToDoListItemEntity.dueDate, ascending: true)
    tasks = coreDataManager.fetch(predicate: nil, sortDescriptors: [sortDescriptor])
  }
  
  @MainActor func addTask(title: String, priority: Int16, dueDate: Date) {
    let newTask = ToDoListItemEntity(context: coreDataManager.viewContext)
    newTask.id = UUID()
    newTask.title = title
    newTask.priority = priority
    newTask.dueDate = dueDate
    newTask.isCompleted = false
    
    coreDataManager.saveContext()
  }
  
  @MainActor func updateTask(_ task: ToDoListItemEntity) {
    coreDataManager.saveContext()
  }
  
  @MainActor func updateTaskTitle(_ task: ToDoListItemEntity, newTitle: String) {
    task.title = newTitle
    updateTask(task)
  }
  
  @MainActor func toggleTaskCompletion(_ task: ToDoListItemEntity) {
    task.isCompleted.toggle()
    updateTask(task)
  }
  
  @MainActor func deleteTask(_ task: ToDoListItemEntity) {
    coreDataManager.viewContext.delete(task)
    coreDataManager.saveContext()
  }
}

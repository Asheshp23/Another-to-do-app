//
//  AppDependencies.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-05.
//
import Foundation

class AppDependencies {
  let coreDataStack: CoreDataStackProtocol
  let coreDataManager: CoreDataManagerProtocol
  
  init(coreDataStack: CoreDataStackProtocol? = nil, coreDataManager: CoreDataManagerProtocol? = nil) {
    self.coreDataStack = coreDataStack ?? CoreDataStack()
    self.coreDataManager = coreDataManager ?? CoreDataManager(stack: self.coreDataStack)
  }
}

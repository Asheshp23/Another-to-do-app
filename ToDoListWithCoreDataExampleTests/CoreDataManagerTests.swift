//
//  CoreDataManagerTests.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-26.
//
import XCTest
import CoreData
@testable import ToDoListWithCoreDataExample

class CoreDataManagerTests: XCTestCase {
  
  var coreDataManager: CoreDataManager!
  
  // Mock or in-memory persistence controller setup
  override func setUpWithError() throws {
    super.setUp()
    
    // Set up a mock or in-memory persistence controller
    let mockPersistenceController = PersistenceController(inMemory: true)
    coreDataManager = CoreDataManager(stack: mockPersistenceController)
  }
  
  override func tearDownWithError() throws {
    coreDataManager = nil
    super.tearDown()
  }
  
  // Test saving and fetching a managed object
  func testSaveAndFetch() throws {
    let newObject = ToDoListItemEntity(context: coreDataManager.viewContext)
    newObject.id = UUID()
    newObject.title = "Test Object"
    
    coreDataManager.saveContext() // Save the context
    
    let fetchedObjects: [ToDoListItemEntity] = coreDataManager.fetch(predicate: nil, sortDescriptors: nil)
    XCTAssertEqual(fetchedObjects.count, 1)
    XCTAssertEqual(fetchedObjects.first?.title, "Test Object")
  }
  
  // Test thread safety by fetching objects from background queue
  func testFetchInBackground() throws {
    let expectation = XCTestExpectation(description: "Fetch in background")
    
    DispatchQueue.global().async {
      let newObject = ToDoListItemEntity(context: self.coreDataManager.viewContext)
      newObject.id = UUID()
      newObject.title = "Test Object"
      self.coreDataManager.saveContext()
      
      let fetchedObjects: [ToDoListItemEntity] = self.coreDataManager.fetch(predicate: nil, sortDescriptors: nil)
      XCTAssertEqual(fetchedObjects.count, 1)
      XCTAssertEqual(fetchedObjects.first?.title, "Test Object")
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5)
  }
  
  // Test async fetch by id
  func testAsyncFetchById() async throws {
    let newObject = ToDoListItemEntity(context: coreDataManager.viewContext)
    let objectId = UUID()
    newObject.id = objectId
    newObject.title = "Test Object"
    coreDataManager.saveContext()
    
    do {
      let fetchedObject: ToDoListItemEntity = try await coreDataManager.fetchById(id: objectId)
      XCTAssertEqual(fetchedObject.title, "Test Object")
    } catch {
      XCTFail("Fetching object failed: \(error)")
    }
  }
  
  // Test error handling for fetchById when object is not found
  func testFetchByIdNotFound() async {
    let invalidId = UUID()
    do {
      _ = try await coreDataManager.fetchById(id: invalidId)
      XCTFail("Expected error but fetch succeeded")
    } catch CoreDataManagerError.objectNotFound {
      // Expected error
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  // Test saving changes in a background queue
  func testSaveContextInBackground() {
    let expectation = XCTestExpectation(description: "Save context in background")
    
    DispatchQueue.global().async {
      let newObject = ToDoListItemEntity(context: self.coreDataManager.viewContext)
      newObject.id = UUID()
      newObject.title = "Test Object"
      self.coreDataManager.saveContext()
      
      let fetchedObjects: [ToDoListItemEntity] = self.coreDataManager.fetch(predicate: nil, sortDescriptors: nil)
      XCTAssertEqual(fetchedObjects.count, 1)
      XCTAssertEqual(fetchedObjects.first?.title, "Test Object")
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5)
  }
}

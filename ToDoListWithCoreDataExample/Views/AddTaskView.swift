//
//  AddTaskView.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-05.
//
import SwiftUI

struct AddTaskView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var viewModel: TodoViewModel
  
  @State private var taskTitle = ""
  @State private var taskPriority = 1
  @State private var taskDueDate = Date()
  
  let priorities = [0, 1, 2]
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Task Details")) {
          TextField("Task Title", text: $taskTitle)
          
          Picker("Priority", selection: $taskPriority) {
            ForEach(priorities, id: \.self) { priority in
              Text(priorityString(for: priority))
            }
          }
          
          DatePicker("Due Date", selection: $taskDueDate, displayedComponents: .date)
        }
        
        Section {
          Button(action: addTask) {
            Text("Add Task")
          }
          .disabled(taskTitle.isEmpty)
        }
      }
      .navigationTitle("Add New Task")
      .navigationBarItems(trailing: Button("Cancel") {
        presentationMode.wrappedValue.dismiss()
      })
    }
  }
  
  private func addTask() {
    viewModel.addTask(title: taskTitle, priority: Int16(taskPriority), dueDate: taskDueDate)
    presentationMode.wrappedValue.dismiss()
  }
  
  private func priorityString(for priority: Int) -> String {
    switch priority {
    case 0:
      return "Low"
    case 1:
      return "Medium"
    case 2:
      return "High"
    default:
      return "Unknown"
    }
  }
}

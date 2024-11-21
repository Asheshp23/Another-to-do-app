//
//  NeumorphicPrioritySection.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import SwiftUI

struct NeumorphicPrioritySection: View {
  let priority: Int
  let tasks: [ToDoListItemEntity]
  @ObservedObject var viewModel: TodoViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Priority Header
      HStack {
        priorityIcon
        
        VStack(alignment: .leading) {
          Text(priorityTitle)
            .font(.headline)
          Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s")")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        NeumorphicProgressView(progress: completionProgress)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 15)
          .fill(Color(UIColor.systemBackground))
          .neumorphicShadow()
      )
      
      // Task List
      ForEach(tasks) { task in
        NeumorphicTaskRow(task: task, viewModel: viewModel)
      }
    }
  }
  
  private var priorityIcon: some View {
    Image(systemName: priorityIconName)
      .foregroundColor(.white)
      .frame(width: 40, height: 40)
      .background(priorityColor)
      .cornerRadius(10)
  }
  
  private var priorityTitle: String {
    switch priority {
    case 2...:
      return "High Priority"
    case 1:
      return "Medium Priority"
    case 0:
      return "Low Priority"
    default:
      return "No Priority"
    }
  }
  
  private var priorityIconName: String {
    switch priority {
    case 3...:
      return "exclamationmark.3"
    case 2:
      return "exclamationmark.2"
    case 1:
      return "exclamationmark"
    default:
      return "minus"
    }
  }
  
  private var priorityColor: Color {
    switch priority {
    case 2...:
      return .red
    case 1:
      return .orange
    case 0:
      return .blue
    default:
      return .gray
    }
  }
  
  private var completionProgress: Double {
    let completedTasks = tasks.filter { $0.isCompleted }.count
    return completedTasks > 0 ? Double(completedTasks) / Double(tasks.count) : 0
  }
}

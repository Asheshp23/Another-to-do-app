//
//  NeumorphicTaskRow.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import SwiftUI

struct NeumorphicTaskRow: View {
  let task: ToDoListItemEntity
  @ObservedObject var viewModel: TodoViewModel
  
  var body: some View {
    HStack {
      // Checkbox
      NeumorphicCheckbox(isChecked: task.isCompleted) {
        viewModel.toggleTaskCompletion(task)
      }
      
      VStack(alignment: .leading) {
        Text(task.title)
          .strikethrough(task.isCompleted)
          .foregroundColor(task.isCompleted ? .secondary : .primary)
      }
      
      Spacer()
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(Color(UIColor.systemBackground))
        .neumorphicShadow()
    )
  }
}

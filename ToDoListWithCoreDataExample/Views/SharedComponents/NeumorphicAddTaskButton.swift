//
//  NeumorphicAddTaskButton.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import SwiftUI

struct NeumorphicAddTaskButton: View {
  let color: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: "plus.circle.fill")
          .foregroundColor(color)
        Text("New Actionable Item")
          .fontWeight(.medium)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 15)
          .fill(Color(UIColor.systemBackground))
          .neumorphicShadow()
      )
    }
  }
}

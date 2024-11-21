//
//  NeumorphicCheckbox.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import SwiftUI

struct NeumorphicCheckbox: View {
  let isChecked: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(UIColor.systemBackground))
          .neumorphicShadow()
        
        if isChecked {
          Image(systemName: "checkmark")
            .foregroundColor(.blue)
        }
      }
      .frame(width: 30, height: 30)
    }
  }
}

//
//  NeumorphicNavBar.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import SwiftUI

struct NeumorphicNavBar: View {
  let title: String
  let leftAction: () -> Void
  let rightAction: () -> Void
  
  var body: some View {
    HStack {
      Spacer()
      
      Text(title)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
      
      Spacer()
    }
    .padding()
    .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.top))
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
  }
}

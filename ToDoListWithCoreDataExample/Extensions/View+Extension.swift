//
//  View+Extension.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import Foundation
import SwiftUICore

extension View {
  func neumorphicShadow() -> some View {
    self
      .shadow(color: .black.opacity(0.1), radius: 5, x: 3, y: 3)
      .shadow(color: .white.opacity(0.7), radius: 5, x: -3, y: -3)
  }
}

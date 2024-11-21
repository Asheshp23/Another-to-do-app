//
//  NeumorphicButton.swift
//  ToDoListWithCoreDataExample
//
//  Created by Ashesh Patel on 2024-11-20.
//
import SwiftUI

struct NeumorphicButton: View {
  let systemImage: String
  let action: () -> Void
  var color: Color = .blue
  var isPressed: Bool = false
  
  @State private var isTapped = false
  
  var body: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.1)) {
        isTapped = true
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.easeInOut(duration: 0.1)) {
          isTapped = false
        }
      }
      
      action()
    }) {
      ZStack {
        // Background
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(UIColor.systemBackground))
        
        // Outer Shadow
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(UIColor.systemBackground))
          .shadow(color: .black.opacity(0.2), radius: 4, x: 3, y: 3)
          .shadow(color: .white.opacity(0.7), radius: 4, x: -3, y: -3)
          .offset(x: isTapped ? 1 : 0, y: isTapped ? 1 : 0)
        
        // Icon
        Image(systemName: systemImage)
          .foregroundColor(color)
          .font(.system(size: 20, weight: .medium))
      }
      .frame(width: 50, height: 50)
      .scaleEffect(isTapped ? 0.95 : 1.0)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// Preview for the Neumorphic Button
struct NeumorphicButtonPreview: View {
  var body: some View {
    VStack(spacing: 20) {
      // Different color variants
      HStack {
        NeumorphicButton(systemImage: "plus", action: {}, color: .blue)
        NeumorphicButton(systemImage: "minus", action: {}, color: .green)
        NeumorphicButton(systemImage: "xmark", action: {}, color: .red)
      }
      
      // Demonstrating different sizes could be achieved by adjusting frame
      HStack {
        NeumorphicButton(systemImage: "gear", action: {}, color: .purple)
          .frame(width: 40, height: 40)
        
        NeumorphicButton(systemImage: "ellipsis", action: {}, color: .orange)
          .frame(width: 60, height: 60)
      }
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
  }
}

#Preview {
  NeumorphicButtonPreview()
}

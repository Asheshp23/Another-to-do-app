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

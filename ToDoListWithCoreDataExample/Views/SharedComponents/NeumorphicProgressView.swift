struct NeumorphicProgressView: View {
  let progress: Double
  
  var body: some View {
    ZStack {
      // Background Circle
      Circle()
        .fill(Color(UIColor.systemBackground))
        .neumorphicShadow()
      
      // Progress Circle
      Circle()
        .trim(from: 0, to: CGFloat(progress))
        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
        .foregroundColor(.blue)
        .rotationEffect(Angle(degrees: -90))
      
      // Percentage Text
      Text(String(format: "%.0f%%", progress * 100))
        .font(.caption)
        .fontWeight(.bold)
    }
    .frame(width: 50, height: 50)
  }
}

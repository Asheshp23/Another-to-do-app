import SwiftUI

struct ToDoListView: View {
  @StateObject private var viewModel = TodoViewModel(coreDataManager: AppDependencies().coreDataManager)
  @State private var showingAddTask = false
  @State private var selectedListColor: Color = .blue
  var body: some View {
    List {
      ForEach(priorityGroups.keys.sorted().reversed(), id: \.self) { priority in
        Section(header: priorityHeader(for: priority)) {
          ForEach(priorityGroups[priority] ?? [], id: \.self) { task in
            ToDoItemRow(viewModel: viewModel, task: task)
          }
        }
      }
      Button(action: { showingAddTask = true }) {
        HStack {
          Image(systemName: "plus.circle.fill")
            .foregroundColor(selectedListColor)
          Text("New actionable item")
            .foregroundColor(.primary)
        }
      }
    }
    .listStyle(InsetGroupedListStyle())
    .navigationTitle("Actionable items")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
          Button("Blue") { selectedListColor = .blue }
          Button("Green") { selectedListColor = .green }
          Button("Orange") { selectedListColor = .orange }
          Button("Red") { selectedListColor = .red }
          Button("Purple") { selectedListColor = .purple }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
      ToolbarItem(placement: .navigationBarLeading) {
        EditButton()
      }
    }
    .sheet(isPresented: $showingAddTask) {
      AddTaskView(viewModel: viewModel)
    }
  }
  
  private var priorityGroups: [Int: [ToDoListItemEntity]] {
    Dictionary(grouping: viewModel.tasks) { Int($0.priority) }
  }
  
  private func priorityHeader(for priority: Int) -> some View {
    HStack(spacing: 12) {
      priorityIcon(for: priority)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(priorityTitle(for: priority))
          .font(.headline)
          .foregroundColor(.primary)
        
        Text("\(priorityGroups[priority]?.count ?? 0) task\(priorityGroups[priority]?.count == 1 ? "" : "s")")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      progressView(for: priority)
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
    .background(priorityColor(for: priority).opacity(0.1))
    .cornerRadius(8)
  }
  
  private func priorityIcon(for priority: Int) -> some View {
    Image(systemName: priorityIconName(for: priority))
      .foregroundColor(.white)
      .frame(width: 32, height: 32)
      .background(priorityColor(for: priority))
      .cornerRadius(8)
  }
  
  private func priorityIconName(for priority: Int) -> String {
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
  
  private func progressView(for priority: Int) -> some View {
    let completedTasks = priorityGroups[priority]?.filter { $0.isCompleted }.count ?? 0
    let totalTasks = priorityGroups[priority]?.count ?? 0
    let progress = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
    
    return CircularProgressView(progress: progress)
      .frame(width: 40, height: 40)
  }
  
  struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
      ZStack {
        Circle()
          .stroke(lineWidth: 4)
          .opacity(0.3)
          .foregroundColor(Color.gray)
        
        Circle()
          .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
          .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
          .foregroundColor(Color.blue)
          .rotationEffect(Angle(degrees: 270.0))
          .animation(.linear, value: progress)
        
        Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
          .font(.system(size: 10))
          .bold()
      }
    }
  }

  
  private func priorityTitle(for priority: Int) -> String {
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
  
  private func priorityColor(for priority: Int) -> Color {
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
}

#Preview {
  ToDoListView()
}

import SwiftUI

struct ToDoListView: View {
  @StateObject private var viewModel = TodoViewModel()
  @State private var showingAddTask = false
  @State private var selectedListColor: Color = .blue
  
  var body: some View {
    ZStack {
      // Background with soft color
      Color(UIColor.systemGroupedBackground)
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        // Custom Navigation Bar
        NeumorphicNavBar(title: "Actionable Items",
                         leftAction: { },
                         rightAction: { showingAddTask = true })
        
        ScrollView {
          VStack(spacing: 15) {
            ForEach(priorityGroups.keys.sorted().reversed(), id: \.self) { priority in
              Section {
                NeumorphicPrioritySection(
                  priority: priority,
                  tasks: priorityGroups[priority] ?? [],
                  viewModel: viewModel
                )
              }
            }
            
            // Add New Task Button
            NeumorphicAddTaskButton(
              color: selectedListColor,
              action: { showingAddTask = true }
            )
            .padding(.vertical)
          }
          .padding()
        }
      }
    }
    .sheet(isPresented: $showingAddTask) {
      AddTaskView(viewModel: viewModel)
    }
  }
  
  private var priorityGroups: [Int: [ToDoListItemEntity]] {
    Dictionary(grouping: viewModel.tasks) { Int($0.priority) }
  }
}

#Preview {
  ToDoListView()
}

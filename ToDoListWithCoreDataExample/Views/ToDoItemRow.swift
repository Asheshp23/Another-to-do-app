import SwiftUI

struct ToDoItemRow: View {
  @ObservedObject var viewModel: TodoViewModel
  let task: ToDoListItemEntity
  @State private var isEditing = false
  @State private var editedTitle: String = ""
  
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Button(action: {
          viewModel.toggleTaskCompletion(task)
        }) {
          Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundColor(task.isCompleted ? .blue : .gray)
            .font(.system(size: 24))
        }
        .buttonStyle(PlainButtonStyle())
        
        if isEditing {
          TextField("Task title", text: $editedTitle, onCommit: {
            viewModel.updateTaskTitle(task, newTitle: editedTitle)
            isEditing = false
          })
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.vertical, 8)
        } else {
          Text(task.title)
            .strikethrough(task.isCompleted)
            .foregroundColor(task.isCompleted ? .gray : .primary)
            .font(.headline)
            .onTapGesture {
              editedTitle = task.title
              isEditing = true
            }
        }
        
        Spacer()
      }
      
      HStack(spacing: 12) {
        if let createdDate = task.createdDate {
          Label(dateFormatter.string(from: createdDate), systemImage: "calendar")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        if let dueDate = task.dueDate {
          Label(dateFormatter.string(from: dueDate), systemImage: "clock")
            .font(.caption)
            .foregroundColor(isDueDatePassed(dueDate) ? .red : .secondary)
        }
      }
      .padding(.top, 2)
    }
    .padding(.vertical, 8)
    .background(Color(UIColor.systemBackground))
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
  }

  private func isDueDatePassed(_ date: Date) -> Bool {
    return date < Date()
  }
}

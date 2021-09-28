import SwiftUI

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}

struct ProjectListView: View {
  let projects: [ProjectCellItem]
  let username: String?
  let tapLogin: () -> Void
  
  var body: some View{
    List {
      if let username = username {
        Text(username)
          .font(.caption)
          .foregroundColor(.secondary)
      } else {
        Button(action: tapLogin) {
          Text("Login")
        }
      }
      Text("Projects")
        .font(.largeTitle)
        .foregroundColor(.primary)
        .padding()
      ForEach(projects) { project in
        Text(project.name)
      }
    }
  }
}

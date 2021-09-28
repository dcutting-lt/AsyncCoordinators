import SwiftUI

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}

struct ProjectListView: View {
  let projects: [ProjectCellItem]
  
  var body: some View{
    List {
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

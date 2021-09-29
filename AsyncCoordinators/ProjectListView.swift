import SwiftUI

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}

struct ProjectListView: View {
  let projects: [ProjectCellItem]
  
  var body: some View{
    List {
      ForEach(projects) { project in
        Text(project.name)
      }
    }
    .navigationTitle("Projects")
  }
}

struct AccountIndicatorView: View {
  var title: String
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(title, systemImage: "person.crop.circle")
        .labelStyle(.titleAndIcon)
    }
  }
}

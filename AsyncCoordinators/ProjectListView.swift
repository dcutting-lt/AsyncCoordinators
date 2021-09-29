import SwiftUI

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}

struct ProjectListView: View {
  let projects: [ProjectCellItem]
  let accountButtonTitle: String
  let tapAccountButton: () -> Void
  
  var body: some View{
    List {
      ForEach(projects) { project in
        Text(project.name)
      }
    }
    .navigationTitle("Projects")
    .toolbar {
      Button(action: tapAccountButton) {
        Text(accountButtonTitle)
      }
    }
  }
}

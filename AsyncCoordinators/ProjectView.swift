import SwiftUI

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}

struct ProjectView: View {
  let projects: [ProjectCellItem]
  
  var body: some View{
    List(projects) {
      Text($0.name)
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

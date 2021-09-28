import Foundation

class ProjectLoader {
  var allProjects: [Project] {
    get async {
      await pause(seconds: 5)
      return [
        Project(id: UUID(), name: "Photoleap"),
        Project(id: UUID(), name: "Videoleap"),
        Project(id: UUID(), name: "Lightleap"),
        Project(id: UUID(), name: "Boosted"),
      ]
    }
  }
}

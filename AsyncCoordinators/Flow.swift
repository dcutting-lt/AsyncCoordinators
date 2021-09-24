import SwiftUI



// FLOWS.

class AppFlow: ObservableObject {
  enum Screen: Equatable {
    case splash
    case home([ProjectCellItem])
  }

  @MainActor @Published var screen = Screen.splash
  @MainActor @Published var isShowingLogin = false

  var loginFlow: LoginFlow?

  func start() async {
    async let projects = ProjectLoader().allProjects
    await pause(seconds: 2)
    let user = await login()
    await showHome(projects: projects, user: user)
  }

  @MainActor func login() async -> User? {
    // TODO: handle swipe dismiss.
    let loginFlow = LoginFlow()
    self.isShowingLogin = true
    self.loginFlow = loginFlow
    defer {
      self.isShowingLogin = false
      self.loginFlow = nil
    }
    return await loginFlow.start()
  }

  @MainActor func showHome(projects: [Project], user: User?) async {
    let projectCellItems = makeProjectCellItems(projects: projects)
    self.screen = .home(projectCellItems)
  }

  private func makeProjectCellItems(projects: [Project]) -> [ProjectCellItem] {
    projects
      .sorted { $0.name < $1.name }
      .map { project in
        ProjectCellItem(id: project.id, name: project.name.uppercased())
      }
  }
}

class LoginFlow: ObservableObject {
  @Published var username = ""
  @Published var password = ""
  var loginTaps = TapStream()

  func start() async -> User? {
    for await _ in loginTaps.stream {
      if username == "Dan" && password == "Pass" {
        return User(id: UUID())
      } else {
        await reset()
      }
    }
    return nil
  }

  @MainActor func reset() {
    username = ""
    password = ""
  }
}



// SERVICES.

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



// MODELS.

struct User {
  let id: UUID

  static let empty = User(id: UUID())
}

struct Project {
  let id: UUID
  var name: String

  static let empty = Project(id: UUID(), name: "")
}

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}



// UTILITIES.

// Pause for a number of seconds in an async context.
func pause(seconds: UInt64) async {
  await Task.sleep(seconds * 1_000_000_000)
}

// Convert imperative function call to an AsyncSequence.
// TODO: check for leaks.
struct TapStream {
  lazy var stream: AsyncStream<Void> = {
    AsyncStream(Void.self) { continuation in
      self.continuation = continuation
    }
  }()
  private var continuation: AsyncStream<Void>.Continuation?

  func tap() {
    continuation?.yield()
  }
}

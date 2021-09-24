import SwiftUI

enum Screen: Equatable {
  case splash
  case home([ProjectCellItem])
}

class Flow: ObservableObject {
  @MainActor @Published var screen = Screen.splash
  @MainActor @Published var isShowingLogin = false

  var loginFlow: LoginFlow?

  private let projectStore = ProjectStore()

  func start() async {
    async let projects = projectStore.allProjects
    await pause(seconds: 2)
    let user = await login()
    await showHome(projects: projects, user: user)
  }

  @MainActor func showHome(projects: [Project], user: User?) async {
    print("show home")
    let projectCellItems = projects
      .sorted { $0.name < $1.name }
      .map { project in
        ProjectCellItem(id: project.id, name: project.name.uppercased())
      }
    self.screen = .home(projectCellItems)
  }

  @MainActor func login() async -> User? {
    let loginFlow = LoginFlow()
    self.isShowingLogin = true
    self.loginFlow = loginFlow
    defer {
      self.isShowingLogin = false
      self.loginFlow = nil
    }
    return await loginFlow.start()
  }
}

struct User {
  let id: UUID

  static let empty = User(id: UUID())
}

struct Project {
  let id: UUID
  var name: String

  static let empty = Project(id: UUID(), name: "")
}

actor ProjectStore {
  var allProjects: [Project] {
    get async {
      print("load projects")
      await pause(seconds: 5)
      defer { print("end load projects") }
      return [
        Project(id: UUID(), name: "Photoleap"),
        Project(id: UUID(), name: "Videoleap"),
        Project(id: UUID(), name: "Lightleap"),
        Project(id: UUID(), name: "Boosted"),
      ]
    }
  }
}

typealias TapStream = AsyncStream<Void>.Continuation

class LoginFlow: ObservableObject {
  @Published var username = ""
  @Published var password = ""

  private var tapStream: TapStream?

  func start() async -> User? {
    print("start login")
    let logins = makeTapStream(for: &tapStream)
    for await attempt in logins {
      print("attempt: \(attempt)")
      if username == "Dan" && password == "Pass" {
        return User(id: UUID())
      } else {
        await reset()
      }
    }
    return nil
  }

  func makeTapStream(for stream: inout TapStream?) -> AsyncStream<Void> {
    AsyncStream(Void.self) { continuation in
      stream = continuation
    }
  }

  @MainActor func reset() {
    username = ""
    password = ""
  }

  func login() {
    print("tap login")
    self.tapStream?.yield()
  }
}

func pause(seconds: UInt64) async {
  await Task.sleep(seconds * 1_000_000_000)
}

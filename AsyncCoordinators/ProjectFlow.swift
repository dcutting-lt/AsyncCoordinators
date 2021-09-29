import SwiftUI

@MainActor
class ProjectFlow: ObservableObject {
  fileprivate enum Action {
    case login
    case logout
  }

  @Published var projects: [ProjectCellItem]
  @Published var username: String?
  @Published var isShowingLogin = false {
    willSet {
      if !newValue {
        loginFlow?.cancel()
      }
    }
  }
  fileprivate var actions = EventStream<Action>()
  var loginFlow: LoginFlow?

  init(projects: [Project], user: User?) {
    self.projects = Self.makeProjectCellItems(projects: projects)
    self.username = user?.username
  }

  func run() async {
    print(">> ProjectFlow start")
    defer { print(">> ProjectFlow stop") }

    for await action in actions.stream {
      switch action {
      case .login:
        self.username = (await runLogin())?.username
      case .logout:
        self.username = nil
      }
    }
  }

  private func runLogin() async -> User? {
    self.loginFlow = LoginFlow()
    self.isShowingLogin = true
    defer {
      self.loginFlow = nil
      self.isShowingLogin = false
    }
    return await loginFlow?.run()
  }

  private static func makeProjectCellItems(projects: [Project]) -> [ProjectCellItem] {
    projects
      .sorted { $0.name < $1.name }
      .map { project in
        ProjectCellItem(id: project.id, name: project.name.uppercased())
      }
  }
}

struct ProjectFlowView: View {
  @ObservedObject var flow: ProjectFlow

  var body: some View {
    NavigationView {
      ProjectListView(projects: flow.projects,
                      accountButtonTitle: flow.username ?? "Login",
                      tapAccountButton: { flow.actions.add(flow.username == nil ? .login : .logout) })
        .sheet(isPresented: $flow.isShowingLogin) {
          if let loginFlow = flow.loginFlow {
            LoginFlowView(flow: loginFlow)
          }
        }
    }
  }
}

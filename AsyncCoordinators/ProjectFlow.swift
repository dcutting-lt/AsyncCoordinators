import SwiftUI

@MainActor
class ProjectFlow: ObservableObject {
  // These are the only actions the project flow can handle.
  fileprivate enum Action {
    case login
    case requestLogout
    case logout
  }

  @Published fileprivate var projects: [ProjectCellItem]
  @Published fileprivate var loggedInUser: User?
  @Published fileprivate var isShowingLogoutAlert = false
  @Published fileprivate var loginFlow: LoginFlow? {
    willSet {
      loginFlow?.abortFlow()  // This is called when the user swipes to dismiss the login sheet.
    }
  }
  fileprivate var actions = EventStream<Action>()

  init(projects: [Project], user: User?) {
    self.projects = Self.makeProjectCellItems(projects: projects)
    self.loggedInUser = user
  }

  // The run loop for the project flow never ends since it's the main screen of the app.
  func run() async {
    print(">> ProjectFlow start")
    defer { print(">> ProjectFlow stop") }

    // Sequentially handle the actions for this flow (forever).
    for await action in actions.stream {
      switch action {
      case .login:
        self.loggedInUser = await runLoginFlow()
      case .requestLogout:
        self.isShowingLogoutAlert = true
      case .logout:
        self.loggedInUser = nil
      }
    }
  }

  private func runLoginFlow() async -> User? {
    self.loginFlow = LoginFlow()
    defer { self.loginFlow = nil }
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
      ProjectView(projects: flow.projects)
        .sheet(item: $flow.loginFlow) {
          LoginFlowView(flow: $0)
        }
        .alert("Are you sure you want to logout?", isPresented: $flow.isShowingLogoutAlert) {
          Button("Cancel", role: .cancel) {}
          Button("Logout", role: .destructive) { flow.actions.add(.logout) }
        }
        .toolbar {
          ToolbarItemGroup {
            if let user = flow.loggedInUser {
              AccountIndicatorView(title: user.username) {
                flow.actions.add(.requestLogout)
              }
            } else {
              AccountIndicatorView(title: "Login") {
                flow.actions.add(.login)
              }
            }
          }
        }
    }
  }
}

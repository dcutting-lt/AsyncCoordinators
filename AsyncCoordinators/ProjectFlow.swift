import SwiftUI

@MainActor
class ProjectFlow: ObservableObject {
  fileprivate enum Action {
    case login
    case logout
  }

  @Published fileprivate var projects: [ProjectCellItem]
  @Published fileprivate var user: User?
  @Published fileprivate var loginFlow: LoginFlow? {
    willSet {
      loginFlow?.abortFlow()  // Need this to handle swipe dismiss of sheet.
    }
  }
  fileprivate var actions = EventStream<Action>()

  init(projects: [Project], user: User?) {
    self.projects = Self.makeProjectCellItems(projects: projects)
    self.user = user
  }

  // The run loop for the project flow never ends since it's the main screen of the app.
  func run() async {
    print(">> ProjectFlow start")
    defer { print(">> ProjectFlow stop") }

    // Sequentially handle the actions for this flow.
    for await action in actions.stream {
      switch action {
      case .login:
        self.user = await runLoginFlow()
      case .logout:
        self.user = nil
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
      ProjectListView(projects: flow.projects)
        .sheet(item: $flow.loginFlow) {
          LoginFlowView(flow: $0)
        }
        .toolbar {
          ToolbarItemGroup {
            if let user = flow.user {
              AccountIndicatorView(title: user.username) {
                flow.actions.add(.logout)
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

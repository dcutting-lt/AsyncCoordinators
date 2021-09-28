import SwiftUI

@MainActor
class MainFlow: ObservableObject {
  enum Screen: Equatable {
    case splash
    case projectList([ProjectCellItem], String?)
  }

  @Published var screen = Screen.splash
  @Published var loginFlow: LoginFlow? {
    willSet {
      loginFlow?.actions.add(.tapCancel)  // Need this to handle swipe dismiss of sheet.
    }
  }

  func run() async {
    async let projects = ProjectLoader().allProjects
    await pause(seconds: 2)
    let user = await runLogin()
    await showProjectList(projects: projects, user: user)
  }

  func runLogin() async -> User? {
    self.loginFlow = LoginFlow()
    defer { self.loginFlow = nil }
    return await loginFlow?.run()
  }

  func showProjectList(projects: [Project], user: User?) async {
    let projectCellItems = makeProjectCellItems(projects: projects)
    self.screen = .projectList(projectCellItems, user?.username)
  }

  private func makeProjectCellItems(projects: [Project]) -> [ProjectCellItem] {
    projects
      .sorted { $0.name < $1.name }
      .map { project in
        ProjectCellItem(id: project.id, name: project.name.uppercased())
      }
  }
}

struct MainFlowView: View {
  @ObservedObject var flow: MainFlow

  var body: some View {
    Group {
      switch flow.screen {
      case .splash:
        SplashView()
      case .projectList(let projectCellItems, let username):
        ProjectListView(projects: projectCellItems, username: username)
      }
    }
    .ignoresSafeArea()
    .transition(.opacity)
    .animation(.linear, value: flow.screen)
    .sheet(item: $flow.loginFlow) {
      LoginFlowView(flow: $0)
    }
  }
}

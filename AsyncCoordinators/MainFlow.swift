import SwiftUI

@MainActor
class MainFlow: ObservableObject {
  fileprivate enum Screen: Equatable {
    case splash
    case projectList([ProjectCellItem], String?)
  }

  @Published fileprivate var screen = Screen.splash
  @Published fileprivate var loginFlow: LoginFlow? {
    willSet {
      loginFlow?.cancel()  // Need this to handle swipe dismiss of sheet.
    }
  }

  func run() async {
    async let projects = ProjectLoader().allProjects
    await pause(seconds: 2)
    let user = await runLogin()
    showProjectList(projects: await projects, user: user)
  }

  private func runLogin() async -> User? {
    self.loginFlow = LoginFlow()
    defer { self.loginFlow = nil }
    return await loginFlow?.run()
  }

  private func showProjectList(projects: [Project], user: User?) {
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

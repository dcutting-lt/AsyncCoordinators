import SwiftUI

@MainActor
class MainFlow: ObservableObject {
  enum Screen: Equatable {
    case splash
    case projectList([ProjectCellItem], String?)
  }

  @Published var screen = Screen.splash
  @Published var isShowingLogin = false

  var loginFlow: LoginFlow?

  func run() async {
    async let projects = ProjectLoader().allProjects
    await pause(seconds: 2)
    let user = await login()
    await showHome(projects: projects, user: user)
  }

  func login() async -> User? {
    // TODO: handle swipe dismiss.
    let loginFlow = LoginFlow()
    self.isShowingLogin = true
    self.loginFlow = loginFlow
    defer {
      self.isShowingLogin = false
      self.loginFlow = nil
    }
    return await loginFlow.run()
  }

  func showHome(projects: [Project], user: User?) async {
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
    .sheet(isPresented: $flow.isShowingLogin) {
      if let loginFlow = flow.loginFlow {
        LoginFlowView(flow: loginFlow)
      }
    }
  }
}

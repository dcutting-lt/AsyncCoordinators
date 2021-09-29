import SwiftUI

@MainActor
class MainFlow: ObservableObject {
  fileprivate enum Screen {
    case splash
    case projects(ProjectFlow)
  }

  @Published fileprivate var screen = Screen.splash
  @Published fileprivate var loginFlow: LoginFlow? {
    willSet {
      loginFlow?.cancel()  // Need this to handle swipe dismiss of sheet.
    }
  }

  func run() async {
    print(">> MainFlow start")
    defer { print(">> MainFlow stop") }

    async let projects = ProjectLoader().allProjects
    await pause(seconds: 1)
    let user = await runLoginFlow()
    await runProjectFlow(projects: await projects, user: user)
  }

  private func runLoginFlow() async -> User? {
    self.loginFlow = LoginFlow()
    defer { self.loginFlow = nil }
    return await loginFlow?.run()
  }

  private func runProjectFlow(projects: [Project], user: User?) async {
    let projectFlow = ProjectFlow(projects: projects, user: user)
    self.screen = .projects(projectFlow)
    await projectFlow.run()
  }
}

struct MainFlowView: View {
  @ObservedObject var flow: MainFlow

  var body: some View {
    Group {
      switch flow.screen {
      case .splash:
        SplashView()
      case .projects(let flow):
        ProjectFlowView(flow: flow)
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

extension MainFlow.Screen: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.splash, .splash):
      return true
    case (.projects, .projects):
      return true
    default:
      return false
    }
  }
}

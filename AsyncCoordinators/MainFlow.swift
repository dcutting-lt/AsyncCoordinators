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
      loginFlow?.abortFlow()  // Need this to handle swipe dismiss of sheet.
    }
  }

  // The entire flow of the app from start to finish.
  func run() async {
    print(">> MainFlow start")
    defer { print(">> MainFlow stop") }

    async let projects = ProjectLoader().allProjects      // Load projects in the background.
    await pause(seconds: 1)                               // Show splash screen for a second.
    let user = await runLoginFlow()                       // Ask the user to login.
    await runProjectFlow(projects: projects, user: user)  // Launch the project flow (which never ends).
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
    .sheet(item: $flow.loginFlow) {
      LoginFlowView(flow: $0)
    }
  }
}

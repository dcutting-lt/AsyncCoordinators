import SwiftUI

struct FlowView: View {
  @ObservedObject var flow: Flow
  
  var body: some View {
    Group {
      switch flow.screen {
      case .splash:
        SplashView()
      case .home(let projectCellItems):
        HomeView(projects: projectCellItems)
      }
    }
    .ignoresSafeArea()
    .transition(.opacity)
    .animation(.linear, value: flow.screen)
    .sheet(isPresented: $flow.isShowingLogin) {
      if let loginFlow = flow.loginFlow {
        LoginView(flow: loginFlow)
      }
    }
  }
}

struct SplashView: View {
  var body: some View {
    ZStack {
      Color.yellow
      VStack {
        Text("Loading...")
          .font(.largeTitle)
          .foregroundColor(.primary)
          .padding()
        ProgressView()
          .colorMultiply(Color.black)
      }
    }
  }
}

struct ProjectCellItem: Equatable, Identifiable {
  let id: UUID
  let name: String
}

struct HomeView: View {
  let projects: [ProjectCellItem]
  
  var body: some View{
    List {
      Text("Projects")
        .font(.largeTitle)
        .foregroundColor(.primary)
        .padding()
      ForEach(projects) { project in
        Text(project.name)
      }
    }
  }
}

struct LoginView: View {
  @ObservedObject var flow: LoginFlow

  var body: some View {
    VStack {
      Text("login")
      TextField("Username", text: $flow.username, prompt: nil)
      TextField("Password", text: $flow.password, prompt: nil)
      Button(action: flow.login) {
        Text("Login")
      }
    }
  }
}

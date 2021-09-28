import SwiftUI

class LoginFlow: ObservableObject {
  enum Action {
    case tapLogin
    case tapCancel
  }

  @Published var username = ""
  @Published var password = ""
  var actions = EventStream<Action>()

  func run() async -> User? {
    let userLoader = UserLoader()

  actions: for await action in actions.stream {
      switch action {
      case .tapLogin:
        do {
          return try await userLoader.load(username: username, password: password)
        } catch {
          await reset()
        }
      case .tapCancel:
        break actions
      }
    }

    return nil
  }

  @MainActor func reset() {
    username = ""
    password = ""
  }
}

struct LoginView: View {
  @ObservedObject var flow: LoginFlow

  var body: some View {
    VStack {
      Text("Login")
      TextField("Username", text: $flow.username, prompt: nil)
      TextField("Password", text: $flow.password, prompt: nil)
      Button {
        flow.actions.add(.tapLogin)
      } label: {
        Text("Login")
      }
      Button {
        flow.actions.add(.tapCancel)
      } label: {
        Text("Cancel")
      }
    }
    .font(.title)
    .padding()
  }
}

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
struct LoginFlowView: View {
  @ObservedObject var flow: LoginFlow

  var body: some View {
    LoginView(
      username: $flow.username,
      password: $flow.password,
      tapLogin: { flow.actions.add(.tapLogin) },
      tapCancel: { flow.actions.add(.tapCancel) }
    )
  }
}

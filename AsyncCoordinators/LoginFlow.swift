import SwiftUI

@MainActor
class LoginFlow: ObservableObject {
  enum Action {
    case tapLogin
    case tapCancel
  }

  @Published var username = ""
  @Published var password = ""
  @Published var isLoadingUser = false
  var actions = EventStream<Action>()

  func run() async -> User? {
    let userLoader = UserLoader()

  actionLoop: for await action in actions.stream {
      switch action {
      case .tapLogin:
        do {
          self.isLoadingUser = true
          defer { self.isLoadingUser = false }
          return try await userLoader.load(username: username, password: password)
        } catch {
          reset()
        }
      case .tapCancel:
        break actionLoop
      }
    }

    return nil
  }

  func reset() {
    self.username = ""
    self.password = ""
  }
}
struct LoginFlowView: View {
  @ObservedObject var flow: LoginFlow

  var body: some View {
    LoginView(
      username: $flow.username,
      password: $flow.password,
      isBusy: flow.isLoadingUser,
      tapLogin: { flow.actions.add(.tapLogin) },
      tapCancel: { flow.actions.add(.tapCancel) }
    )
  }
}

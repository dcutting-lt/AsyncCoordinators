import SwiftUI

@MainActor
class LoginFlow: ObservableObject, Identifiable {
  // These are the only actions the login flow can handle.
  fileprivate enum Action {
    case login
    case cancel
  }

  @Published fileprivate var username = ""
  @Published fileprivate var password = ""
  @Published fileprivate var isLoadingUser = false
  fileprivate var actions = EventStream<Action>()

  // The run loop for the login flow ends either when the user successfully logs in or cancels.
  // If logged in, the User object is returned.
  func run() async -> User? {
    print(">> LoginFlow start")
    defer { print(">> LoginFlow stop") }

    // Sequentially handle the actions for this flow until the user logs in or cancels.
    for await action in actions.stream {
      switch action {
      case .login:
        do {
          self.isLoadingUser = true
          defer { self.isLoadingUser = false }
          return try await UserLoader().load(username: username, password: password)
        } catch {
          reset()
        }
      case .cancel:
        return nil
      }
    }

    return nil
  }

  // This is needed because the login flow can be aborted by the user with a swipe dismiss,
  // which cannot be directly intercepted.
  func abortFlow() {
    actions.add(.cancel)
  }

  private func reset() {
    self.username = ""
    self.password = ""
  }
}

// This FlowView bridges the flow logic to a SwiftUI view.
struct LoginFlowView: View {
  @ObservedObject var flow: LoginFlow

  var body: some View {
    LoginView(
      username: $flow.username,
      password: $flow.password,
      isBusy: flow.isLoadingUser,
      tapLogin: { flow.actions.add(.login) },
      tapCancel: { flow.actions.add(.cancel) }
    )
  }
}

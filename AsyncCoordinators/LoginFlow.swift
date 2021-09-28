import SwiftUI

@MainActor
class LoginFlow: ObservableObject, Identifiable {
  fileprivate enum Action {
    case login
    case cancel
  }

  @Published fileprivate var username = ""
  @Published fileprivate var password = ""
  @Published fileprivate var isLoadingUser = false
  fileprivate var actions = EventStream<Action>()

  func run() async -> User? {
    let userLoader = UserLoader()

  actionLoop: for await action in actions.stream {
      switch action {
      case .login:
        do {
          self.isLoadingUser = true
          defer { self.isLoadingUser = false }
          return try await userLoader.load(username: username, password: password)
        } catch {
          reset()
        }
      case .cancel:
        break actionLoop
      }
    }

    return nil
  }

  func cancel() {
    actions.add(.cancel)
  }

  private func reset() {
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
      tapLogin: { flow.actions.add(.login) },
      tapCancel: { flow.actions.add(.cancel) }
    )
  }
}

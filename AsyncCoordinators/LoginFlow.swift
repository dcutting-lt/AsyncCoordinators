import SwiftUI

class LoginFlow: ObservableObject {
  @Published var username = ""
  @Published var password = ""
  var loginTaps = TapStream()

  func run() async -> User? {
    for await _ in loginTaps.stream {
      if username == "Dan" && password == "Pass" {
        return User(id: UUID())
      } else {
        await reset()
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
      Button(action: flow.loginTaps.tap) {
        Text("Login")
      }
    }
    .font(.title)
    .padding()
  }
}

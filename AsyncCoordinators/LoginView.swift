import SwiftUI

struct LoginView: View {
  @Binding var username: String
  @Binding var password: String
  var tapLogin: () -> Void
  var tapCancel: () -> Void

  var body: some View {
    VStack {
      Text("Login")
      TextField("Username", text: $username, prompt: nil)
      TextField("Password", text: $password, prompt: nil)
      Button(action: tapLogin) {
        Text("Login")
      }
      Button(action: tapCancel) {
        Text("Cancel")
      }
    }
    .font(.title)
    .padding()
  }
}

import SwiftUI

struct LoginView: View {
  @Binding var username: String
  @Binding var password: String
  var isBusy: Bool
  var tapLogin: () -> Void
  var tapCancel: () -> Void

  var body: some View {
    VStack {
      Text("Login")
      if isBusy {
        ProgressView()
      } else {
        TextField("Username", text: $username, prompt: nil)
        TextField("Password", text: $password, prompt: nil)
        Button(action: tapLogin) {
          Text("Login")
        }
        Button(action: tapCancel) {
          Text("Cancel")
        }
      }
    }
    .font(.title)
    .padding()
  }
}

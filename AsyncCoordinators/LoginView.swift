import SwiftUI

struct LoginView: View {
  @Binding var username: String
  @Binding var password: String
  var isBusy: Bool
  var tapLogin: () -> Void
  var tapCancel: () -> Void

  var body: some View {
    ZStack {
      Color.yellow
      VStack {
        if isBusy {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            .scaleEffect(2)
        } else {
          Text("Login")
            .font(.largeTitle)
          TextField("Username", text: $username, prompt: nil)
            .foregroundColor(.black)
          TextField("Password", text: $password, prompt: nil)
            .foregroundColor(.black)
          HStack {
            Button(action: tapCancel) {
              Text("Cancel")
            }
            Button(action: tapLogin) {
              Text("Login")
            }
          }
          .padding()
        }
      }
      .font(.title)
      .foregroundColor(.white)
      .buttonStyle(.bordered)
      .textFieldStyle(.roundedBorder)
      .padding()
    }
    .ignoresSafeArea()
  }
}

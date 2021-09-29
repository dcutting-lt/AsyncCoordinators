import SwiftUI

struct SplashView: View {
  var body: some View {
    ZStack {
      Color.purple
      VStack {
        Text("Loading...")
          .font(.largeTitle)
          .foregroundColor(.white)
          .padding()
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
          .scaleEffect(2)
      }
    }
  }
}

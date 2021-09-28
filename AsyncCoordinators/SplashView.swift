import SwiftUI

struct SplashView: View {
  var body: some View {
    ZStack {
      Color.yellow
      VStack {
        Text("Loading...")
          .font(.largeTitle)
          .foregroundColor(.primary)
          .padding()
        ProgressView()
          .colorMultiply(Color.black)
      }
    }
  }
}

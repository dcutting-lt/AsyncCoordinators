import SwiftUI

@main
struct AsyncCoordinatorsApp: App {
  @StateObject var flow = AppFlow()

  var body: some Scene {
    WindowGroup {
      AppFlowView(flow: flow)
        .onAppear {
          Task { await self.flow.start() }
        }
    }
  }
}

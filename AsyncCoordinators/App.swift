import SwiftUI

@main
struct AsyncCoordinatorsApp: App {
  @StateObject var flow = MainFlow()

  var body: some Scene {
    WindowGroup {
      MainFlowView(flow: flow)
        .onAppear {
          Task { await self.flow.run() }
        }
    }
  }
}

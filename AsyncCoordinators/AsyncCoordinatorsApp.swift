import SwiftUI

@main
struct AsyncCoordinatorsApp: App {
  @StateObject var flow = Flow()

  var body: some Scene {
    WindowGroup {
      FlowView(flow: flow)
        .onAppear {
          Task { await self.flow.start() }
        }
    }
  }
}

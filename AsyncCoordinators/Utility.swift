// Pause for a number of seconds in an async context.
func pause(seconds: UInt64) async {
  await Task.sleep(seconds * 1_000_000_000)
}

// Convert imperative function call to an AsyncSequence.
// TODO: check for leaks.
struct TapStream {
  lazy var stream: AsyncStream<Void> = {
    AsyncStream(Void.self) { continuation in
      self.continuation = continuation
    }
  }()
  private var continuation: AsyncStream<Void>.Continuation?

  func tap() {
    continuation?.yield()
  }
}

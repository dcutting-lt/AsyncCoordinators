// Pause for a number of seconds in an async context.
func pause(seconds: UInt64) async {
  await Task.sleep(seconds * 1_000_000_000)
}

// Convert imperative function call to an AsyncSequence.
// TODO: check for leaks.
struct EventStream<T> {
  lazy var stream: AsyncStream<T> = {
    AsyncStream(T.self) { continuation in
      self.continuation = continuation
    }
  }()
  private var continuation: AsyncStream<T>.Continuation?

  func add(_ element: T) {
    continuation?.yield(element)
  }
}

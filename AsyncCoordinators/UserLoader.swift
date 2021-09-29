import Foundation

class UserLoader {
  enum Error: Swift.Error {
    case invalid
  }

  func load(username: String, password: String) async throws -> User {
    await pause(seconds: 1)
    let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty && !password.isEmpty else { throw Error.invalid }
    return User(id: UUID(), username: trimmed)
  }
}

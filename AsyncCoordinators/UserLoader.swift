import Foundation

class UserLoader {
  enum Error: Swift.Error {
    case invalid
  }

  func load(username: String, password: String) async throws -> User {
    await pause(seconds: 2)
    guard username == "Dan" && password == "Pass" else { throw Error.invalid }
    return User(id: UUID())
  }
}

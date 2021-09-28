import Foundation

class UserLoader {
  enum Error: Swift.Error {
    case invalid
  }

  func load(username: String, password: String) async throws -> User {
    guard username == "Dan" && password == "Pass" else { throw Error.invalid }
    return User(id: UUID())
  }
}

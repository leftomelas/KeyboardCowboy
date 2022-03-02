import Foundation

public struct TypeCommand: Identifiable, Codable, Hashable, Sendable {
  public let id: String
  public var name: String
  public var input: String
  public var isEnabled: Bool = true

  public init(id: String = UUID().uuidString,
              name: String,
              input: String) {
    self.id = id
    self.name = name
    self.input = input
  }
}

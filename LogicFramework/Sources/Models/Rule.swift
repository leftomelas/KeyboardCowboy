import Foundation

public enum Rule: Codable, Hashable {
  /// Activate when an application is front-most
  case application(Application)
  /// Only active during certain days
  case days([Day])

  enum CodingKeys: CodingKey {
    case application
    case days
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    switch container.allKeys.first {
    case .application:
      let value = try container.decode(Application.self, forKey: .application)
      self = .application(value)
    case .days:
      let value = try container.decode([Day].self, forKey: .days)
      self = .days(value)
    case .none:
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Unabled to decode enum."
        )
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .application(let application):
      try container.encode(application, forKey: .application)
    case .days(let days):
      try container.encode(days, forKey: .days)
    }
  }

  public enum Day: Int, Codable, Hashable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
  }

}
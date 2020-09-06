@testable import LogicFramework
import Foundation
import SnapshotTesting
import XCTest

class KeyboardCommandTests: XCTestCase {
  enum KeyboardCommandTestError: Error {
    case unableToProduceString
  }

  func testJSONEncoding() throws {
    assertSnapshot(matching: try ModelFactory().keyboardCommand().toString(), as: .dump)
  }

  func testJSONDecoding() throws {
    let json = ["output": "A"]
    XCTAssertEqual(try KeyboardCommand.decode(from: json), ModelFactory().keyboardCommand())
  }
}

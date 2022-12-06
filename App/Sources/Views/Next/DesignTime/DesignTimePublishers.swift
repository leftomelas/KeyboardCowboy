import Foundation
import Cocoa

enum DesignTime {
  static let sourceRoot = ProcessInfo.processInfo.environment["SOURCE_ROOT"] ?? "SOURCE_ROOT"

  static var configurationPublisher = ConfigurationPublisher {
    [
      ConfigurationViewModel(id: UUID().uuidString, name: UUID().uuidString),
      ConfigurationViewModel(id: UUID().uuidString, name: UUID().uuidString),
    ]
  }

  static var groupsPublisher = GroupsPublisher {
    [
      GroupViewModel(id: UUID().uuidString, name: "fn-key", image: nil, color: "", symbol: "", count: 24),
      GroupViewModel(id: UUID().uuidString, name: "Finder", image: nil, color: "", symbol: "", count: 10),
      GroupViewModel(id: UUID().uuidString, name: "Safari", image: nil, color: "", symbol: "", count: 5),
      GroupViewModel(id: UUID().uuidString, name: "Xcode", image: nil, color: "", symbol: "", count: 2),
      GroupViewModel(id: UUID().uuidString, name: "Apple News", image: nil, color: "", symbol: "", count: 0),
      GroupViewModel(id: UUID().uuidString, name: "Messages", image: nil, color: "", symbol: "", count: 1),
      GroupViewModel(id: UUID().uuidString, name: "Global", image: nil, color: "", symbol: "", count: 50),
      GroupViewModel(id: UUID().uuidString, name: "Web pages", image: nil, color: "", symbol: "", count: 14),
      GroupViewModel(id: UUID().uuidString, name: "Development", image: nil, color: "", symbol: "", count: 6),
      GroupViewModel(id: UUID().uuidString, name: "Folders", image: nil, color: "", symbol: "", count: 8),
    ]
  }
  static var contentPublisher = ContentPublisher {
   [
    ContentViewModel(id: UUID().uuidString, name: "Open News", images: [], binding: "ƒSpace", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Podcast", images: [], binding: "ƒU", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Music", images: [], binding: "ƒY", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Home", images: [], binding: "ƒH", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Twitterific", images: [], binding: "ƒT", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open System Preferences", images: [], binding: "ƒ.", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Contacts", images: [], binding: "ƒA", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Terminal", images: [], binding: "ƒ§", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Discord", images: [], binding: "ƒD", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Preview", images: [], binding: "ƒP", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Teams", images: [], binding: "ƒG", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Slack", images: [], binding: "ƒV", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Find My", images: [], binding: "ƒB", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Messages", images: [], binding: "ƒD", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Mail", images: [], binding: "ƒM", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Calendar", images: [], binding: "ƒC", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Reminders", images: [], binding: "ƒR", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Notes", images: [], binding: "ƒN", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Safari", images: [], binding: "ƒS", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Finder", images: [], binding: "ƒF", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Photos", images: [], binding: "ƒI", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Stocks", images: [], binding: "ƒS", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Keyboard Cowboy", images: [], binding: "⌥ƒ0", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Numbers", images: [], binding: "⌥ƒN", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Pages", images: [], binding: "⌥ƒP", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Keynote", images: [], binding: "⌥ƒK", badge: 0, badgeOpacity: 0),
    ContentViewModel(id: UUID().uuidString, name: "Open Quick Run", images: [], binding: "ƒK", badge: 0, badgeOpacity: 0),
   ]
  }
  static var detailPublisher = DetailPublisher {
    .single(detail)
  }

  static var detail: DetailViewModel {

    let homeDirectory = ("~/" as NSString).expandingTildeInPath
    let scriptFile = Self.sourceRoot.appending("/Fixtures/AppleScript.scpt")
    //("~/Library/Mobile Documents/com~apple~CloudDocs/Keyboard Cowboy/Shortcuts.scpt" as NSString).expandingTildeInPath

    return DetailViewModel(
      id: UUID().uuidString,
      name: "Open News",
      isEnabled: true,
      trigger: .keyboardShortcuts([.init(id: UUID().uuidString,
                                         displayValue: "f", modifier: .shift)]),
      commands: [
        .init(id: UUID().uuidString,
              name: "News",
              kind: .application,
              image: NSWorkspace.shared.icon(forFile: "/System/Applications/News.app"),
              isEnabled: true),

        .init(id: UUID().uuidString,
              name: "Home Folder",
              kind: .open(appName: nil),
              image: NSWorkspace.shared.icon(forFile: homeDirectory),
              isEnabled: true),

        .init(id: UUID().uuidString,
              name: scriptFile,
              kind: .script(.path(id: UUID().uuidString, fileExtension: "scpt")),
              image: NSWorkspace.shared.icon(forFile: scriptFile),
              isEnabled: true),

          .init(id: UUID().uuidString,
                name: "Left align the Dock",
                kind: .script(.inline(id: UUID().uuidString, type: "script")),
                image: NSWorkspace.shared.icon(forFile: scriptFile),
                isEnabled: true),
      ])
  }
}
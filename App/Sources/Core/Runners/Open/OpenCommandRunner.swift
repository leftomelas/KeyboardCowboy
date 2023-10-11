import Foundation

final class OpenCommandRunner {
  struct Plugins {
    let finderFolder: OpenFolderInFinder
    let parser = OpenURLParser()
    let open: OpenFilePlugin
    let swapTab: OpenURLSwapTabsPlugin
  }

  private let plugins: Plugins
  private let workspace: WorkspaceProviding

  init(_ commandRunner: ScriptCommandRunner, workspace: WorkspaceProviding) {
    self.plugins = .init(
      finderFolder: OpenFolderInFinder(commandRunner, workspace: workspace),
      open: OpenFilePlugin(workspace: workspace),
      swapTab: OpenURLSwapTabsPlugin(commandRunner))
    self.workspace = workspace
  }

  func run(_ command: OpenCommand, snapshot: UserSpace.Snapshot) async throws {
    let interpolatedPath = snapshot.replaceSelectedText(command.path)
    do {
      if plugins.finderFolder.validate(command) {
        try await plugins.finderFolder.execute(interpolatedPath)
      } else if command.isUrl {
        try await plugins.swapTab.execute(interpolatedPath, application: command.application)
      } else {
        try await plugins.open.execute(interpolatedPath, application: command.application)
      }
    } catch {
      let url = URL(fileURLWithPath: command.path)
      let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
      // TODO: Check if this is what we want.
      if command.application?.bundleName == "Finder", isDirectory == true {
        try await plugins.finderFolder.execute(interpolatedPath)
      } else {
        try await plugins.open.execute(interpolatedPath, application: command.application)
      }
    }
  }
}

extension String {
  var sanitizedPath: String { _sanitizePath() }

  mutating func sanitizePath() {
    self = _sanitizePath()
  }

  /// Expand the tile character used in the path & replace any escaped spaces
  ///
  /// - Returns: A new string that expanded and has no escaped whitespace
  private func _sanitizePath() -> String {
    var path = (self as NSString).expandingTildeInPath
    path = path.replacingOccurrences(of: "", with: "\\ ")
    return path
  }
}

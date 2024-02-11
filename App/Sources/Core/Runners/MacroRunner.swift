import Foundation
import MachPort

final class MacroRunner {
  private let coordinator: MacroCoordinator
  private let bezelId = "com.zenangst.Keyboard-Cowboy.MacroRunner"

  init(coordinator: MacroCoordinator) {
    self.coordinator = coordinator
  }

  func run(_ macroAction: MacroAction, 
           shortcut: KeyShortcut,
           machPortEvent: MachPortEvent) async -> String {
    let output: String
    switch macroAction.kind {
      case .list:
        output = "List Macros"
      case .record:
        if let newMacroKey = coordinator.newMacroKey {
          coordinator.state = .idle
          output = "Recorded Macro for \(newMacroKey.modifersDisplayValue) \(newMacroKey.key)"
        } else {
          coordinator.state = .recording
          output = "Choose Macro key..."
        }
      case .remove:
        output = "Remove Macro key..."
    }

    Task { @MainActor [bezelId] in
      BezelNotificationController.shared.post(.init(id: bezelId, text: output))
    }

    return output
  }
}

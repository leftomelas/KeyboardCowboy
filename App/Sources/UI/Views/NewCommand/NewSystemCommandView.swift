import Bonzai
import SwiftUI

struct NewCommandSystemCommandView: View {
  @Binding var payload: NewCommandPayload
  @Binding var validation: NewCommandValidation

  @State private var kind: SystemCommand.Kind? = nil

  init(_ payload: Binding<NewCommandPayload>, validation: Binding<NewCommandValidation>) {
    _payload = payload
    _validation = validation
  }

  var body: some View {
    VStack(alignment: .leading) {
      ZenLabel("System Command:")

      HStack {
        switch kind {
        case .activateLastApplication:
          ActivateLastApplicationIconView(size: 24)
        case .applicationWindows:
          MissionControlIconView(size: 24)
        case .minimizeAllOpenWindows:
          MinimizeAllIconView(size: 24)
        case .missionControl:
          MissionControlIconView(size: 24)
        case .moveFocusToNextWindow:
          MoveFocusToWindowIconView(direction: .next, scope: .visibleWindows, size: 24)
        case .moveFocusToNextWindowFront:
          MoveFocusToWindowIconView(direction: .next, scope: .activeApplication, size: 24)
        case .moveFocusToNextWindowGlobal:
          MoveFocusToWindowIconView(direction: .next, scope: .allWindows, size: 24)
        case .moveFocusToPreviousWindow:
          MoveFocusToWindowIconView(direction: .previous, scope: .allWindows, size: 24)
        case .moveFocusToPreviousWindowFront:
          MoveFocusToWindowIconView(direction: .previous, scope: .activeApplication, size: 24)
        case .moveFocusToPreviousWindowGlobal:
          MoveFocusToWindowIconView(direction: .previous, scope: .allWindows, size: 24)
        case .showDesktop:
          DockIconView(size: 24)
        case .none:
          EmptyView()
        }
        Menu {
          ForEach(SystemCommand.Kind.allCases) { kind in
            Button {
              self.kind = kind
              validation = updateAndValidatePayload()
            } label: {
              Image(systemName: kind.symbol)
              Text(kind.displayValue)
            }
          }
        } label: {
          if let kind {
            Image(systemName: kind.symbol)
            Text(kind.displayValue)
          } else {
            Text("Select system command")
          }
        }
      }
      .background(NewCommandValidationView($validation))
    }
    .menuStyle(.regular)
    .onChange(of: validation, perform: { newValue in
      guard newValue == .needsValidation else { return }
      withAnimation { validation = updateAndValidatePayload() }
    })
    .onAppear {
      validation = .unknown
    }
  }

  @discardableResult
  private func updateAndValidatePayload() -> NewCommandValidation {
    guard let kind else { return .invalid(reason: "Pick a system command.") }

    payload = .systemCommand(kind: kind)

    return .valid
  }
}

struct NewCommandSystemCommandView_Previews: PreviewProvider {
  static var previews: some View {
    NewCommandView(
      workflowId: UUID().uuidString,
      commandId: nil,
      title: "New command",
      selection: .system,
      payload: .systemCommand(kind: .applicationWindows),
      onDismiss: {},
      onSave: { _, _ in })
    .designTime()
  }
}

import SwiftUI

struct KeyboardCommandView: View {
  enum Action {
    case updateName(newName: String)
    case updateKeyboardShortcuts([KeyShortcut])
    case commandAction(CommandContainerAction)
  }

  @Binding private var command: DetailViewModel.CommandViewModel
  @State private var name: String
  @State private var keyboardShortcuts: [KeyShortcut]
  private let onAction: (Action) -> Void

  init(_ command: Binding<DetailViewModel.CommandViewModel>, onAction: @escaping (Action) -> Void) {
    _command = command
    _name = .init(initialValue: command.wrappedValue.name)
    self.onAction = onAction

    if case .keyboard(let keyboardShortcuts) = command.wrappedValue.kind {
      _keyboardShortcuts = .init(initialValue: keyboardShortcuts)
    } else {
      _keyboardShortcuts = .init(initialValue: [])
    }
  }

  var body: some View {
    CommandContainerView(
      $command, icon: {
        ZStack {
          Rectangle()
            .fill(Color(.systemGreen))
            .opacity(0.2)
            .cornerRadius(8)
          ZStack {
            RegularKeyIcon(letter: "")
            Image(systemName: "flowchart")
          }
          .scaleEffect(0.8)
        }
      }, content: {
        HStack {
          TextField("", text: $name)
            .textFieldStyle(AppTextFieldStyle())
            .onChange(of: name, perform: {
              onAction(.updateName(newName: $0))
            })
          Spacer()
        }
      },
      subContent: {
        EditableKeyboardShortcutsView(keyboardShortcuts: $keyboardShortcuts)
          .onChange(of: keyboardShortcuts) { newValue in
            onAction(.updateKeyboardShortcuts(newValue))
          }
          .padding(.horizontal, 2)
          .background(Color(.windowBackgroundColor).opacity(0.25))
          .cornerRadius(4)
      },
      onAction: { onAction(.commandAction($0)) })
  }
}

struct RebindingCommandView_Previews: PreviewProvider {
  static var previews: some View {
    KeyboardCommandView(.constant(DesignTime.rebindingCommand), onAction: { _ in })
      .frame(maxHeight: 80)
  }
}
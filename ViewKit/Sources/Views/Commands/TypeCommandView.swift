import SwiftUI
import ModelKit

struct TypeCommandView: View {
  let command: Command
  let editAction: (Command) -> Void
  let showContextualMenu: Bool

  var body: some View {
    HStack {
      ZStack {
        IconView(path: "/System/Library/PreferencePanes/Keyboard.prefPane")
          .frame(width: 32, height: 32)
      }
      VStack(alignment: .leading, spacing: 0) {
        Text(command.name)
        if showContextualMenu {
          HStack(spacing: 4) {
            Button(action: { editAction(command) }, label: {
              Text("Edit")
            }).foregroundColor(Color(.controlAccentColor))
          }.buttonStyle(LinkButtonStyle())
          .font(Font.caption)
        }
      }
    }
  }
}

struct TypeCommandView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    KeyboardCommandView(
      command: .type(TypeCommand(name: "Name", input: "Input")),
      editAction: { _ in },
      showContextualMenu: true)
  }
}
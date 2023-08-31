import SwiftUI

struct SidebarUpdateConfigurationNamePopoverView: View {
  @Binding private var updateConfigurationNamePopover: Bool
  @Binding private var configurationName: String
  private let onAction: (String) -> Void

  init(_ updateConfigurationNamePopover: Binding<Bool>,
       configurationName: Binding<String>,
       onAction: @escaping (String) -> Void) {
    _configurationName = configurationName
    _updateConfigurationNamePopover = updateConfigurationNamePopover
    self.onAction = onAction
  }

  var body: some View {
    HStack {
      Text("Configuration name:")
      TextField("", text: $configurationName)
        .frame(width: 170)
        .onSubmit {
          onAction(configurationName)
          updateConfigurationNamePopover = false
          configurationName = ""
        }
      Button("Save", action: {
        onAction(configurationName)
        updateConfigurationNamePopover = false
        configurationName = ""
      })
      .keyboardShortcut(.defaultAction)
      .buttonStyle(.gradientStyle(config: .init(nsColor: .systemGreen, hoverEffect: false)))
    }
    .padding()

  }
}


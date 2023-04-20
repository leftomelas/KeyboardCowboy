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
    HStack {
      Label(title: { Text("System command:") }, icon: { EmptyView() })
        .labelStyle(HeaderLabelStyle())
      Spacer()
      Menu {
        ForEach(SystemCommand.Kind.allCases) { kind in
          Button(kind.displayValue, action: {
            self.kind = kind
            validation = updateAndValidatePayload()
          })
        }
      } label: {
        if let kind {
          Text(kind.displayValue)
        } else {
          Text("Select system command")
        }
      }
      .background(NewCommandValidationView($validation))
    }
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
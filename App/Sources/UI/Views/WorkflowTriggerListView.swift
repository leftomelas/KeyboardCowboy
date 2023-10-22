import Combine
import SwiftUI
import Bonzai

struct WorkflowTriggerListView: View {
  @Namespace var namespace

  private let workflowId: String
  @ObservedObject private var publisher: TriggerPublisher
  private let onAction: (SingleDetailView.Action) -> Void

  var focus: FocusState<AppFocus?>.Binding

  private let applicationTriggerSelectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>
  private let keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>

  init(_ focus: FocusState<AppFocus?>.Binding,
       workflowId: String,
       publisher: TriggerPublisher,
       applicationTriggerSelectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>,
       keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>,
       onAction: @escaping (SingleDetailView.Action) -> Void) {
    self.focus = focus
    self.publisher = publisher
    self.applicationTriggerSelectionManager = applicationTriggerSelectionManager
    self.keyboardShortcutSelectionManager = keyboardShortcutSelectionManager
    self.onAction = onAction
    self.workflowId = workflowId
  }

  var body: some View {
    Group {
      switch publisher.data {
      case .keyboardShortcuts(let trigger):
       KeyboardTriggerView(namespace: namespace, workflowId: workflowId, focus: focus, trigger: trigger,
                           keyboardShortcutSelectionManager: keyboardShortcutSelectionManager, onAction: onAction)
      case .applications(let triggers):
        HStack {
          Label("Application Trigger", image: "")
          Spacer()
          Button(action: { onAction(.removeTrigger(workflowId: workflowId)) },
                 label: {
            Image(systemName: "xmark")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 10, height: 10)
          })
          .buttonStyle(.calm(color: .systemRed, padding: .medium))
        }
        .padding([.leading, .trailing], 8)
        WorkflowApplicationTriggerView(focus, data: triggers,
                                       selectionManager: applicationTriggerSelectionManager) { action in
          onAction(.applicationTrigger(workflowId: workflowId, action: action))
        }
        .matchedGeometryEffect(id: "workflow-triggers", in: namespace)
      case .empty:
        Label("Add Trigger", image: "")
          .padding([.leading, .trailing], 8)
        WorkflowTriggerView(onAction: { action in
          onAction(.trigger(workflowId: workflowId, action: action))
        })
        .matchedGeometryEffect(id: "workflow-triggers", in: namespace)
      }
    }
    .animation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.2), value: publisher.data)
  }
}

struct WorkflowTriggerListView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    VStack {
      WorkflowTriggerListView($focus, workflowId: UUID().uuidString,
                              publisher: .init(DesignTime.detail.trigger),
                              applicationTriggerSelectionManager: .init(),
                              keyboardShortcutSelectionManager: .init()) { _ in }
    }
      .designTime()
      .padding()
      .frame(minHeight: 100)
  }
}

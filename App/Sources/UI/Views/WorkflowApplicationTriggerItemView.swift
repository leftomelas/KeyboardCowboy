import Bonzai
import Inject
import SwiftUI

struct WorkflowApplicationTriggerItemView: View {
  @ObserveInjection var inject
  @Binding var element: DetailViewModel.ApplicationTrigger
  @Binding private var data: [DetailViewModel.ApplicationTrigger]
  @State var isTargeted: Bool = false
  private let selectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>
  private let onAction: (WorkflowApplicationTriggerView.Action) -> Void

  init(_ element: Binding<DetailViewModel.ApplicationTrigger>,
       data: Binding<[DetailViewModel.ApplicationTrigger]>,
       selectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>,
       onAction: @escaping (WorkflowApplicationTriggerView.Action) -> Void) {
    _element = element
    _data = data
    self.selectionManager = selectionManager
    self.onAction = onAction
  }

  var body: some View {
    HStack(spacing: 12) {
      IconView(icon: element.icon, size: .init(width: 24, height: 24))
      VStack(alignment: .leading, spacing: 4) {
        Text(element.name)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.caption)
        HStack {
          ForEach(DetailViewModel.ApplicationTrigger.Context.allCases) { context in
            ZenCheckbox(context.displayValue, style: .small, isOn: Binding<Bool>(get: {
              element.contexts.contains(context)
            }, set: { newValue in
              if newValue {
                element.contexts.append(context)
              } else {
                element.contexts.removeAll(where: { $0 == context })
              }
              onAction(.updateApplicationTriggerContext(element))
            })) { _ in }
              .lineLimit(1)
              .allowsTightening(true)
              .truncationMode(.tail)
              .font(.caption)
          }
        }
      }
      .padding(.vertical, 8)
      ZenDivider(.vertical)
      Button(
        action: {
          withAnimation(WorkflowCommandListView.animation) {
            if let index = data.firstIndex(of: element) {
              data.remove(at: index)
            }
          }
          onAction(.updateApplicationTriggers(data))
        },
        label: {
          Image(systemName: "xmark")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 8, height: 8)
        })
      .buttonStyle(.calm(color: .systemRed, padding: .medium))
    }
    .padding(.leading, 8)
    .padding(.trailing, 16)
    .dropDestination(String.self, color: .accentColor) { items, location in
      guard let payload = items.draggablePayload(prefix: "WAT|"),
            let (from, destination) = data.moveOffsets(for: element,
                                                       with: payload) else {
        return false
      }
      withAnimation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.2)) {
        data.move(fromOffsets: IndexSet(from), toOffset: destination)
      }
      onAction(.updateApplicationTriggers(data))
      return true
    }
    .overlay(BorderedOverlayView(cornerRadius: 8))
    .draggable(element.draggablePayload(prefix: "WAT|", selections: selectionManager.selections))
    .enableInjection()
  }
}

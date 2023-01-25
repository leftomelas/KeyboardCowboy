import Carbon
import SwiftUI
import Inject
import UniformTypeIdentifiers

struct EditableStack<Data, Content>: View where Content: View,
                                                Data: RandomAccessCollection,
                                                Data: MutableCollection,
                                                Data.Element: Identifiable,
                                                Data.Element: Hashable,
                                                Data.Index: Hashable,
                                                Data.Index == Int,
                                                Data.Element.ID: CustomStringConvertible {
  enum Focus: Hashable {
    case focused(Data.Element.ID)
  }

  @FocusState var focus: Focus?
  @Environment(\.resetFocus) var resetFocus

  @Binding var data: Data
  @Binding var selectedColor: Color

  @State private var selections = Set<Data.Element.ID>() { didSet { onSelection(selections) } }
  @State private var draggingIndex: Int?
  @State private var dragging: [Int]?
  @State private var move: EditableStackMoveInstruction?

  private let id: KeyPath<Data.Element, Data.Element.ID>
  private let content: (Binding<Data.Element>) -> Content
  private let cornerRadius: Double
  private let spacing: CGFloat?
  private let axes: Axis.Set
  private let lazy: Bool
  private let elementCount: Int
  private let scrollProxy: ScrollViewProxy?
  private let onClick: (Data.Element.ID, Int) -> Void
  private let onSelection: (Set<Data.Element.ID>) -> Void
  private let onMove: ((_ indexSet: IndexSet, _ toIndex: Int) -> Void)?
  private let onDelete: ((_ indexSet: IndexSet) -> Void)?


  init(_ data: Binding<Data>,
       axes: Axis.Set = .vertical,
       lazy: Bool = false,
       scrollProxy: ScrollViewProxy? = nil,
       spacing: CGFloat? = nil,
       selectedColor: Binding<Color> = .constant(Color.accentColor),
       id: KeyPath<Data.Element, Data.Element.ID> = \.id,
       cornerRadius: Double = 8,
       onClick: @escaping (Data.Element.ID, Int) -> Void = { _ , _ in },
       onSelection: @escaping ((Set<Data.Element.ID>) -> Void) = { _ in },
       onMove: ((_ indexSet: IndexSet, _ toIndex: Int) -> Void)? = nil,
       onDelete: ((_ indexSet: IndexSet) -> Void)? = nil,
       content: @escaping (Binding<Data.Element>) -> Content) {
    _data = data
    _selectedColor = selectedColor
    self.id = id
    self.axes = axes
    self.content = content
    self.cornerRadius = cornerRadius
    self.lazy = lazy
    self.spacing = spacing
    self.scrollProxy = scrollProxy
    self.elementCount = data.count
    self.onClick = onClick
    self.onMove = onMove
    self.onDelete = onDelete
    self.onSelection = onSelection
  }

  var body: some View {
    axesView($data) { element, index in
      interactiveView(element, index: index) { element in
        content(element)
      }
    }
    .enableInjection()
  }

  @ViewBuilder
  private func axesView<Content: View>(_ data: Binding<Data>,
                                       content: @escaping (Binding<Data.Element>, Int) -> Content) -> some View {
    AxesView(axes, lazy: lazy, spacing: spacing) {
      ForEach(data, id: id) { element in
        let index = data.wrappedValue.firstIndex(of: element.wrappedValue) ?? 0
        content(element, index)
          .onDrag({
            let from: [Int]
            if !selections.contains(element.id) {
              selections = []
              from = [index]
            } else if !selections.isEmpty {
              from = data.indices.filter({ selections.contains(data[$0].id) })
            } else {
              from = [index]
            }

            dragging = from
            draggingIndex = index

//            dragging = selections
//            dragging = element.wrappedValue
//            dragging.insert(element.id)

//            let selections = Array(selections).map(String.init).joined(separator: ";")
//            let id = "\(element.id)+\(selections)"

            return NSItemProvider(object: "foo" as NSString)
          }, preview: {
            dragPreview(element)
          })
          .onDrop(
            of: [UTType.text],
            delegate: EditableStackRelocateDelegate(dropIndex: index,
                                                    draggingIndex: $draggingIndex,
                                                    dragging: $dragging,
                                                    move: $move,
                                                    onMove: onMove))
      }
      .onDeleteCommand {
        guard let onDelete else { return }
        if !selections.isEmpty {
          let indexes = selections.compactMap { selection in
            data.firstIndex(where: { $0.id == selection } )
          }
          onDelete(IndexSet(indexes))
        } else if case .focused(let id) = focus,
                  let index = data.firstIndex(where: { $0.id == id }) {
          onDelete(IndexSet(integer: index))
        }
      }
    }
  }

  @ViewBuilder
  private func interactiveView<Content: View>(_ element: Binding<Data.Element>,
                                              index currentIndex: Int,
                                              content: @escaping (Binding<Data.Element>) -> Content) -> some View {
    InteractiveView(
      element,
      index: currentIndex,
      selectedColor: $selectedColor,
      content: { element, _ in content(element) },
      overlay: { element, _ in
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(selectedColor)
          .opacity(selections.contains(element.id) ? 0.2 : 0.0)
          .allowsHitTesting(false)
      },
      onClick: handleClick,
      onKeyDown: { onKeyDown(index: currentIndex, keyCode: $0, modifiers: $1) }
    )
    .overlay(alignment: overlayAlignment(currentIndex: currentIndex),
             content: { dropIndicatorOverlay(elementId: element.id,
                                             currentIndex: currentIndex,
                                             elementCount: elementCount)
    })
    .focused($focus, equals: .focused(element.wrappedValue.id))
    .id(element.id)
  }

  @ViewBuilder
  private func dropIndicatorOverlay(elementId: Data.Element.ID,
                                    currentIndex: Int,
                                    elementCount: Int) -> some View {
    if let draggingIndex, let move {
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(selectedColor)
        .frame(maxWidth: axes == .horizontal ? 2.0 : nil,
               maxHeight: axes == .vertical ? 2.0 : nil)
        .opacity(
          draggingIndex != currentIndex &&
          (move.to == currentIndex || move.to == currentIndex + 1
           && currentIndex == elementCount - 1) &&
          !selections.contains(elementId)
          ? 0.75 : 0.0)
        .allowsHitTesting(false)
    } else {
      EmptyView()
    }
  }

  private func overlayAlignment(currentIndex: Int) -> Alignment {
    guard let move else { return .top }
    let newIndex = move.to
    switch axes {
    case .horizontal:
      return currentIndex >= newIndex ? .leading : .trailing
    default:
      return currentIndex >= newIndex ? .top : .bottom
    }
  }

  @ViewBuilder
  private func dragPreview(_ element: Binding<Data.Element>) -> some View {
    if selections.isEmpty {
      content(element)
    } else {
      content(element)
        .overlay(alignment: .bottomTrailing, content: {
          Text("\(selections.count)")
            .font(.callout)
            .padding(4)
            .background(Circle().fill(.red))
            .offset(x: 4, y: 4)
        })
        .padding()
    }
  }

  private func handleClick(element: Data.Element,
                           index: Int,
                           modifier: InteractiveViewModifier) {
    switch modifier {
    case .empty:
      selections = []
      focus = .focused(element.id)
    case .command:
      focus = .focused(element.id)
      onTapWithCommandModifier(element.id)
    case .shift:
      focus = .focused(element.id)
      onTapWithShiftModifier(element.id)
    }

    self.onClick(element.id, index)
  }

  private func onKeyDown(index: Int,
                         keyCode: Int,
                         modifiers: NSEvent.ModifierFlags) {
    guard case .focused = focus else { return }
    switch keyCode {
    case kVK_ANSI_A:
      if modifiers.contains(.command) {
        selections = Set(data.map(\.id))
      }
    case kVK_Escape:
      selections = []
      focus = nil
    case kVK_DownArrow, kVK_RightArrow:
      let newIndex = index + 1
      if newIndex < data.count {
        let elementId = data[newIndex].id
        focus = .focused(elementId)
        scrollProxy?.scrollTo(elementId)
      }
      selections = []
    case kVK_UpArrow, kVK_LeftArrow:
      let newIndex = index - 1
      if newIndex >= 0 {
        let elementId = data[newIndex].id
        focus = .focused(elementId)
          scrollProxy?.scrollTo(elementId)
      }
      selections = []
    case kVK_Return:
      break
    default:
      break
    }
  }

  private func onTapWithCommandModifier(_ elementId: Data.Element.ID) {
    if selections.contains(elementId) {
      selections.remove(elementId)
    } else {
      selections.insert(elementId)
    }
  }

  private func onTapWithShiftModifier(_ elementId: Data.Element.ID) {
    if selections.contains(elementId) {
      selections.remove(elementId)
    } else {
      selections.insert(elementId)
    }

    if case .focused(let currentElement) = focus {
      let alreadySelected = selections.contains(elementId)
      guard var startIndex = data.firstIndex(where: { $0.id == currentElement }),
            var endIndex = data.firstIndex(where: { $0.id == elementId }) else {
        return
      }
      if endIndex < startIndex {
        let copy = startIndex
        startIndex = endIndex
        endIndex = copy
      }

      data[startIndex...endIndex].forEach { element in
        if !alreadySelected {
          if selections.contains(element.id) {
            selections.remove(element.id)
          }
        } else {
          if !selections.contains(element.id) {
            selections.insert(element.id)
          }
        }
      }
    }
  }
}

private struct EditableStackMoveInstruction {
  let from: IndexSet
  let to: Int
}

private struct EditableStackRelocateDelegate: DropDelegate {
  let dropIndex: Int
  let onMove: ((_ indexSet: IndexSet, _ toIndex: Int) -> Void)?
  @Binding var dragging: [Int]?
  @Binding var draggingIndex: Int?
  @Binding var move: EditableStackMoveInstruction?

  init(dropIndex: Int,
       draggingIndex: Binding<Int?>,
       dragging: Binding<[Int]?>,
       move: Binding<EditableStackMoveInstruction?>,
       onMove: ((_ indexSet: IndexSet, _ toIndex: Int) -> Void)?) {
    _dragging = dragging
    _draggingIndex = draggingIndex
    _move = move
    self.dropIndex = dropIndex
    self.onMove = onMove
  }

  func dropEntered(info: DropInfo) {
    guard onMove != nil,
          let dragging,
          let draggingIndex,
          !dragging.isEmpty else { return }

    if draggingIndex != dropIndex {
      let from = dragging
      move = .init(from: IndexSet(from), to: dropIndex > draggingIndex ? dropIndex + 1 : dropIndex)
    }
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    return DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    guard let onMove, let move else { return false }

    self.dragging = nil
    self.draggingIndex = nil
    self.move = nil

    onMove(move.from, move.to)

    return true
  }
}
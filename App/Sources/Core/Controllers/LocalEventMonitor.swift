import Combine
import Foundation
import SwiftUI

final class LocalEventMonitor: ObservableObject {
  @Published var emptyFlags: Bool = true
  @Published var event: NSEvent?
  @Published var repeatingKeyDown: Bool = false
  @Published var mouseDown: Bool = false
  private var subscription: AnyCancellable?

  @MainActor
  static let shared: LocalEventMonitor = .init()

  fileprivate init() {
    NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .leftMouseDown, .leftMouseUp]) { [weak self] event in
      guard let self else { return event }
      switch event.type {
      case .leftMouseUp:
        self.mouseDown = false
      case .leftMouseDown:
        self.mouseDown = true
      case .flagsChanged:
        let result = event.cgEvent?.flags == CGEventFlags.maskNonCoalesced
        self.emptyFlags = result
        if result {
          self.event = nil
        }
      default:
        break
      }
      return event
    }

    NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { [weak self] event in
      guard let self else { return event }

      self.event = event

      if event.isARepeat {
        repeatingKeyDown = true
      } else {
        repeatingKeyDown = false
      }
      return event
    }
  }
}

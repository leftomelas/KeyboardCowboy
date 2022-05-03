import Combine
import Cocoa
import Foundation
import os

@MainActor
final class KeyboardCowboyEngine {
  private var subscriptions = Set<AnyCancellable>()

  private var menuController: MenubarController?

  private let bundleIdentifier = Bundle.main.bundleIdentifier!
  private let commandEngine: CommandEngine
  private let machPortEngine: MachPortEngine
  private let shortcutStore: ShortcutStore
  private let workflowEngine: WorkflowEngine

  private var machPortController: MachPortController?

  init(_ contentStore: ContentStore, workspace: NSWorkspace = .shared) {
    let keyCodeStore = KeyCodeStore(controller: InputSourceController())
    let commandEngine = CommandEngine(workspace, keyCodeStore: keyCodeStore)
    self.commandEngine = commandEngine
    self.machPortEngine = MachPortEngine(store: keyCodeStore, mode: .intercept)
    self.workflowEngine = .init(
      applicationStore: contentStore.applicationStore,
      commandEngine: commandEngine,
      configStore: contentStore.configurationStore
    )
    self.shortcutStore = ShortcutStore()

    subscribe(to: workspace)

    machPortEngine.subscribe(to: workflowEngine.$activeWorkflows)
    machPortEngine.subscribe(to: workflowEngine.$sequence)
    machPortEngine.subscribe(to: contentStore.recorderStore.$mode)
    workflowEngine.subscribe(to: machPortEngine.$keystroke)

    contentStore.recorderStore.subscribe(to: machPortEngine.$recording)

    guard !isRunningPreview else { return }

    if !hasPrivileges() { } else {
      do {
        let machPortController = try MachPortController()
        commandEngine.eventSource = machPortController.eventSource
        machPortEngine.subscribe(to: machPortController.$event)
        self.machPortController = machPortController
      } catch let error {
        os_log(.error, "\(error.localizedDescription)")
      }
    }

    NSApplication.shared.publisher(for: \.isRunning)
      .sink { [weak self] isRunning in
        guard isRunning else { return }
        self?.menuController = MenubarController(contentStore.applicationStore)
      }
      .store(in: &subscriptions)
  }

  func run(_ commands: [Command], serial: Bool) {
    if serial {
      commandEngine.serialRun(commands)
    } else {
      commandEngine.concurrentRun(commands)
    }
  }

  func reveal(_ commands: [Command]) {
    commandEngine.reveal(commands)
  }

  // MARK: Private methods

  private func hasPrivileges() -> Bool {
    let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
    let privOptions = [trusted: true] as CFDictionary
    let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)

    return accessEnabled
  }

  private func subscribe(to workspace: NSWorkspace) {
    workspace.publisher(for: \.frontmostApplication)
      .compactMap { $0 }
      .sink { [weak self] application in
        self?.reload(with: application)
      }
      .store(in: &subscriptions)
  }

  private func reload(with application: NSRunningApplication) {
    let newPolicy: NSApplication.ActivationPolicy
    if application.bundleIdentifier == bundleIdentifier {
      newPolicy = .regular
    } else {
      newPolicy = .accessory
    }

    NSApplication.shared.setActivationPolicy(newPolicy)
  }
}

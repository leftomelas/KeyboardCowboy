import Cocoa

class MainWindow: NSWindow {
  init(toolbar: Toolbar) {
    let contentRect: CGRect = .init(origin: .zero, size: .init(width: 960, height: 480))
    let styleMask: NSWindow.StyleMask = [
      .titled, .closable, .miniaturizable,
      .fullSizeContentView, .unifiedTitleAndToolbar, .resizable]
    super.init(contentRect: contentRect,
               styleMask: styleMask,
               backing: .buffered,
               defer: false)
    self.toolbar = toolbar
  }
}
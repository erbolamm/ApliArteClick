import Cocoa
import FlutterMacOS

/**
 * MainFlutterWindow: Native macOS bridge for ApliArte Clicker Pro.
 * 
 * Handles system-level mouse events, global coordinate translation, 
 * and accessibility permission checks.
 */
class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let mouseChannel = FlutterMethodChannel(name: "com.apliarte.click/mouse", binaryMessenger: flutterViewController.engine.binaryMessenger)
    mouseChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "performClick" {
        let args = call.arguments as? [String: Any]
        let x = args?["x"] as? Double
        let y = args?["y"] as? Double
        self.performGlobalClick(x: x, y: y)
        result(nil)
      } else if call.method == "getMousePosition" {
        // Return raw global mouse position (Bottom-Left origin in macOS)
        let pos = NSEvent.mouseLocation
        result(["x": pos.x, "y": pos.y])
      } else if call.method == "checkPermissions" {
        result(self.checkAccessibilityPermissions())
      } else if call.method == "isMouseButtonPressed" {
        // Check if left mouse button is currently pressed
        let isPressed = NSEvent.pressedMouseButtons & (1 << 0) != 0
        result(isPressed)
      } else if call.method == "performKeyPress" {
        let args = call.arguments as? [String: Any]
        if let keyCode = args?["keyCode"] as? Int {
            let modifiers = args?["modifiers"] as? [String] ?? []
            self.performGlobalKeyPress(keyCode: CGKeyCode(keyCode), modifiers: modifiers)
        }
        result(nil)
      } else if call.method == "switchApplication" {
        self.performAppSwitch()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  private func performGlobalClick(x: Double?, y: Double?) {
    let mouseLocation = NSEvent.mouseLocation
    // CGEvent coordinates are Y-DOWN, starting from Top-Left of the PRIMARY screen.
    // NSEvent.mouseLocation coordinates are Y-UP, starting from Bottom-Left of the PRIMARY screen.
    guard let primaryScreen = NSScreen.screens.first else { return }
    
    let point: CGPoint
    if let x = x, let y = y {
        // Input x, y are Global Y-UP (Standard macOS)
        // Convert to Global Y-DOWN for CGEvent
        point = CGPoint(x: x, y: primaryScreen.frame.height - y)
    } else {
        // Use current mouse position (already in Global Y-UP)
        // Convert current position to Global Y-DOWN
        point = CGPoint(x: mouseLocation.x, y: primaryScreen.frame.height - mouseLocation.y)
    }
    
    let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
    let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
    
    mouseDown?.post(tap: CGEventTapLocation.cghidEventTap)
    mouseUp?.post(tap: CGEventTapLocation.cghidEventTap)
  }

  private func checkAccessibilityPermissions() -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    return AXIsProcessTrustedWithOptions(options as CFDictionary)
  }

  private func performGlobalKeyPress(keyCode: CGKeyCode, modifiers: [String]) {
    let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
    let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
    
    var flags: CGEventFlags = []
    if modifiers.contains("command") { flags.insert(.maskCommand) }
    if modifiers.contains("alt") { flags.insert(.maskAlternate) }
    if modifiers.contains("shift") { flags.insert(.maskShift) }
    if modifiers.contains("control") { flags.insert(.maskControl) }
    
    keyDown?.flags = flags
    keyUp?.flags = flags
    
    keyDown?.post(tap: CGEventTapLocation.cghidEventTap)
    keyUp?.post(tap: CGEventTapLocation.cghidEventTap)
  }

  private func performAppSwitch() {
    let tabKey: CGKeyCode = 48
    let commandKey: CGKeyCode = 55
    
    let commandDown = CGEvent(keyboardEventSource: nil, virtualKey: commandKey, keyDown: true)
    let tabDown = CGEvent(keyboardEventSource: nil, virtualKey: tabKey, keyDown: true)
    let tabUp = CGEvent(keyboardEventSource: nil, virtualKey: tabKey, keyDown: false)
    let commandUp = CGEvent(keyboardEventSource: nil, virtualKey: commandKey, keyDown: false)
    
    tabDown?.flags = .maskCommand
    tabUp?.flags = .maskCommand
    
    commandDown?.post(tap: CGEventTapLocation.cghidEventTap)
    tabDown?.post(tap: CGEventTapLocation.cghidEventTap)
    tabUp?.post(tap: CGEventTapLocation.cghidEventTap)
    commandUp?.post(tap: CGEventTapLocation.cghidEventTap)
  }
}

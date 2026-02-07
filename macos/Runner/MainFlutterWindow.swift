import Cocoa
import FlutterMacOS

/**
 * MainFlutterWindow: Native macOS bridge for ApliArte Clicker Pro.
 * 
 * Handles system-level mouse events, global coordinate translation, 
 * and accessibility permission checks.
 */
class MainFlutterWindow: NSWindow {
  private var previewWindow: NSWindow?

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
        let button = args?["button"] as? String ?? "left"
        let clickCount = args?["clickCount"] as? Int ?? 1
        self.performGlobalClick(x: x, y: y, button: button, clickCount: clickCount)
        result(nil)
      } else if call.method == "getMousePosition" {
        // Return raw global mouse position (Bottom-Left origin in macOS)
        let pos = NSEvent.mouseLocation
        result(["x": pos.x, "y": pos.y])
      } else if call.method == "checkPermissions" {
        result(self.checkAccessibilityPermissions())
      } else if call.method == "getPressedMouseButtons" {
        // Return raw mask of pressed buttons
        result(NSEvent.pressedMouseButtons)
      } else if call.method == "isMouseButtonPressed" {
        // KEEPING FOR BACKWARD COMPATIBILITY (Target logic uses getPressedMouseButtons now)
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
      } else if call.method == "showPreview" {
        let args = call.arguments as? [String: Any]
        if let x = args?["x"] as? Double, let y = args?["y"] as? Double {
            self.showPreview(x: x, y: y)
        }
        result(nil)
      } else if call.method == "hidePreview" {
        self.hidePreview()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  private func performGlobalClick(x: Double?, y: Double?, button: String, clickCount: Int) {
    let mouseLocation = NSEvent.mouseLocation
    guard let primaryScreen = NSScreen.screens.first else { return }
    
    let point: CGPoint
    if let x = x, let y = y {
        point = CGPoint(x: x, y: primaryScreen.frame.height - y)
    } else {
        point = CGPoint(x: mouseLocation.x, y: primaryScreen.frame.height - mouseLocation.y)
    }
    
    let mouseTypeDown: CGEventType
    let mouseTypeUp: CGEventType
    let cgButton: CGMouseButton
    
    if button == "right" {
        mouseTypeDown = .rightMouseDown
        mouseTypeUp = .rightMouseUp
        cgButton = .right
    } else {
        mouseTypeDown = .leftMouseDown
        mouseTypeUp = .leftMouseUp
        cgButton = .left
    }
    
    let mouseDown = CGEvent(mouseEventSource: nil, mouseType: mouseTypeDown, mouseCursorPosition: point, mouseButton: cgButton)
    let mouseUp = CGEvent(mouseEventSource: nil, mouseType: mouseTypeUp, mouseCursorPosition: point, mouseButton: cgButton)
    
    // Set Click Count (for double/triple clicks)
    mouseDown?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
    mouseUp?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
    
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
    commandUp?.post(tap: CGEventTapLocation.cghidEventTap)
  }

  private func showPreview(x: Double, y: Double) {
    if previewWindow == nil {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 40, height: 40),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = true
        
        let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        if let image = NSImage(systemSymbolName: "hand.point.up.fill", accessibilityDescription: nil) {
            imageView.image = image
            imageView.imageScaling = .scaleProportionallyUpOrDown
            imageView.contentTintColor = .systemBlue
        }

        
        // Enable layers for animation
        imageView.wantsLayer = true 
        window.contentView = imageView
        window.contentView?.wantsLayer = true
        previewWindow = window
    }
    
    guard let primaryScreen = NSScreen.screens.first else { return }
    
    // Adjust y to be bottom-left based
    // Input Y is already Bottom-Left based (from NSEvent.mouseLocation).
    // NSWindow uses Bottom-Left origin.
    // So we assume y is correct "Global Y from Bottom".
    // We want the TOP of our 40px icon to be at 'y'.
    // So Window Origin Y (Bottom of window) = y - 40.
    
    // Ensure we are using main screen height correctly?
    // Actually if y is global, we might not need screen height at all if on primary.
    // But NSEvent is global.
    let winY = y - 40

    let winX = x - 20 // Center horizontally (40/2 = 20)
    
    previewWindow?.setFrameOrigin(NSPoint(x: winX, y: winY))
    previewWindow?.orderFront(nil)
    
    // Add Pulse Animation if not already animating
    // Using opacity instead of transform for safer visual effect on window
    if let layer = previewWindow?.contentView?.layer {
        if layer.animation(forKey: "pulse") == nil {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 1.2
            animation.duration = 0.5
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            // Ensure anchor point is center (default is usually 0.5,0.5 but good to be safe)
            // layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.add(animation, forKey: "pulse")
        }
    }
  }

  private func hidePreview() {
    previewWindow?.orderOut(nil)
  }
}

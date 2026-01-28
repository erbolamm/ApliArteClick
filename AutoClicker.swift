import Foundation
import CoreGraphics
import AppKit

class AutoClicker: ObservableObject {
    @Published var isRunning = false
    @Published var interval: Double = 1000 // In milliseconds
    @Published var hasPermission: Bool = true
    
    private var timer: Timer?
    
    func start() {
        guard !isRunning else { return }
        
        // Check for accessibility permissions
        hasPermission = checkAccessibilityPermissions()
        if !hasPermission {
            return
        }

        isRunning = true
        
        let intervalInSeconds = interval / 1000.0
        timer = Timer.scheduledTimer(withTimeInterval: intervalInSeconds, repeats: true) { [weak self] _ in
            self?.performClick()
        }
        
        // Ensure timer runs even when menu is open or other UI interactions happen
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func performClick() {
        // Get the current mouse position
        let mouseLocation = NSEvent.mouseLocation
        // Convert to flipped coordinate system used by CGEvent (top-left is 0,0)
        // NSEvent.mouseLocation uses bottom-left as 0,0
        guard let screen = NSScreen.main else { return }
        let point = CGPoint(x: mouseLocation.x, y: screen.frame.height - mouseLocation.y)
        
        // Create mouse down event
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        // Create mouse up event
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        
        // Post events to the event tap
        mouseDown?.post(tap: CGEventTapLocation.cghidEventTap)
        mouseUp?.post(tap: CGEventTapLocation.cghidEventTap)
    }

    private func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}

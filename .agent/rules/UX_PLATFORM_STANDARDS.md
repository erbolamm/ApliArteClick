# UX Platform Standards - ApliArte Click Pro

This document defines the visual and behavioral standards that must be maintained across all platforms (macOS, Windows, Linux) to ensure a consistent user experience.

## 1. Touch Location Preview (Native Overlay)

When the user hovers over a target point in the list, a "preview" indicator must appear at the target coordinates.

### Visual Requirements

- **Icon**: A blue hand pointing up.
  - **macOS**: Use SF Symbol `hand.point.up.fill`.
  - **Windows/Linux**: Use `assets/images/hand_preview.png` (a 512x512 blue SF-style hand icon).
- **Color**: System Blue (`#007AFF`).
- **Size**: Approximately 40pt (scaled as appropriate for the platform's DPI).
- **Animation**: "Pulse" effect.
  - Scale oscillates between 0.8x and 1.2x.
  - Duration: ~0.5s - 1.0s per cycle.

### Behavioral Requirements

- **Always on Top**: The preview window must stay above all other windows.
- **Ignore Mouse Events**: The preview must be transparent to clicks (users should click *through* it).
- **Positioning**: The icon should be centered horizontally on the target point, with the "tapping finger" tip positioned at the coordinate (offset adjusted per platform).
- **Cleanup**: The overlay must be hidden/destroyed immediately when `hidePreview` is called.

### Implementation Pattern

- **Native Implementation**: Due to performance and "ignore mouse" requirements, this must be implemented using native platform APIs (not Flutter widgets):
  - **macOS**: `NSWindow` with `NSImageView`.
  - **Windows**: Win32 Layered Window (`WS_EX_LAYERED`) with GDI+ for image drawing.
  - **Linux**: X11 or Wayland overlay (TBD).
- **Communication**: Controlled via a `MethodChannel` named `com.apliarte.click/mouse`.

## 2. Global Hotkeys

- Standardized across platforms via `hotkey_manager`.
- Default "Start/Stop" hotkey should be persistent.

---
*Created on: 2026-02-08*
*Target Version: v3.0.0 (Unified Windows/macOS)*

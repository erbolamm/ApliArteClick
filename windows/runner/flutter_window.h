#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <gdiplus.h>
#include <objidl.h>
#include <windows.h>

#include <memory>
#include <vector>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject &project);
  virtual ~FlutterWindow();

  Gdiplus::Image *overlay_image_ = nullptr;

protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

private:
  void CreateOverlay(double x, double y);
  void ShowOverlay(double x, double y);
  void HideOverlay();

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // Method channel for platform-specific interactions.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      mouse_channel_;

  // Overlay window handle.
  HWND overlay_hwnd_ = nullptr;

  // GDI+ Token
  ULONG_PTR gdiplus_token_ = 0;
};

#endif // RUNNER_FLUTTER_WINDOW_H_

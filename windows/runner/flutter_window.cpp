#include "flutter_window.h"

#include <flutter/generated_plugin_registrant.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

using namespace Gdiplus;

static double g_pulse_scale = 1.0;
static bool g_pulse_up = true;

// Native Overlay Window Procedure
LRESULT CALLBACK OverlayWindowProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
  switch (msg) {
  case WM_NCCREATE: {
    LPCREATESTRUCT lpcs = reinterpret_cast<LPCREATESTRUCT>(lp);
    SetWindowLongPtr(hwnd, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(lpcs->lpCreateParams));
    return TRUE;
  }
  case WM_ERASEBKGND:
    return 1;
  case WM_TIMER:
    if (g_pulse_up) {
      g_pulse_scale += 0.04;
      if (g_pulse_scale >= 1.2)
        g_pulse_up = false;
    } else {
      g_pulse_scale -= 0.04;
      if (g_pulse_scale <= 0.8)
        g_pulse_up = true;
    }
    InvalidateRect(hwnd, NULL, TRUE);
    break;
  case WM_PAINT: {
    PAINTSTRUCT ps;
    HDC hdc = BeginPaint(hwnd, &ps);
    RECT rect;
    GetClientRect(hwnd, &rect);

    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    Graphics graphics(hdc);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    // Clear with transparent background
    graphics.Clear(Color::Transparent);

    // Draw clean blue circle indicator (matching macOS style)
    int centerX = width / 2;
    int centerY = height / 2;
    int radius = static_cast<int>((width / 2 - 3) * g_pulse_scale);

    SolidBrush blueBrush(Color(255, 0, 122, 255)); // #007AFF
    Pen whitePen(Color(255, 255, 255, 255), 2.0f);

    graphics.FillEllipse(&blueBrush, centerX - radius, centerY - radius,
                         radius * 2, radius * 2);
    graphics.DrawEllipse(&whitePen, centerX - radius, centerY - radius,
                         radius * 2, radius * 2);

    EndPaint(hwnd, &ps);
    return 0;
  }
  }
  return DefWindowProc(hwnd, msg, wp, lp);
}

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {
  GdiplusStartupInput gdiplusStartupInput;
  GdiplusStartup(&gdiplus_token_, &gdiplusStartupInput, NULL);
}

FlutterWindow::~FlutterWindow() {
  if (overlay_image_) {
    delete overlay_image_;
    overlay_image_ = nullptr;
  }
  if (gdiplus_token_) {
    GdiplusShutdown(gdiplus_token_);
  }
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  mouse_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "com.apliarte.click/mouse",
          &flutter::StandardMethodCodec::GetInstance());

  mouse_channel_->SetMethodCallHandler([this](const auto &call, auto result) {
    if (call.method_name() == "showPreview") {
      const auto *arguments =
          std::get_if<flutter::EncodableMap>(call.arguments());
      if (arguments) {
        auto x_it = arguments->find(flutter::EncodableValue("x"));
        auto y_it = arguments->find(flutter::EncodableValue("y"));
        if (x_it != arguments->end() && y_it != arguments->end()) {
          double x = 0;
          if (auto x_val = std::get_if<double>(&x_it->second))
            x = *x_val;
          else if (auto x_val_int = std::get_if<int32_t>(&x_it->second))
            x = (double)*x_val_int;

          double y = 0;
          if (auto y_val = std::get_if<double>(&y_it->second))
            y = *y_val;
          else if (auto y_val_int = std::get_if<int32_t>(&y_it->second))
            y = (double)*y_val_int;

          this->ShowOverlay(x, y);
        }
      }
      result->Success();
    } else if (call.method_name() == "hidePreview") {
      this->HideOverlay();
      result->Success();
    } else {
      result->NotImplemented();
    }
  });

  flutter_controller_->engine()->SetNextFrameCallback([&]() { this->Show(); });
  flutter_controller_->ForceRedraw();
  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }
  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }
  switch (message) {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  }
  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::CreateOverlay(double x, double y) {
  if (overlay_hwnd_)
    return;

  WNDCLASSEX wcex = {0};
  wcex.cbSize = sizeof(WNDCLASSEX);
  wcex.style = CS_HREDRAW | CS_VREDRAW;
  wcex.lpfnWndProc = OverlayWindowProc;
  wcex.hInstance = GetModuleHandle(nullptr);
  wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
  wcex.lpszClassName = L"ApliArteOverlayClass";
  RegisterClassEx(&wcex);

  // Create 40x40 window to match macOS
  overlay_hwnd_ = CreateWindowEx(
      WS_EX_TOPMOST | WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_NOACTIVATE,
      L"ApliArteOverlayClass", L"", WS_POPUP, (int)x - 20, (int)y - 40, 40, 40,
      NULL, NULL, GetModuleHandle(nullptr), this);

  SetLayeredWindowAttributes(overlay_hwnd_, 0, 255, LWA_ALPHA);
}

void FlutterWindow::ShowOverlay(double x, double y) {
  if (!overlay_hwnd_) {
    CreateOverlay(x, y);
  }
  // Position: center horizontally (x-20), top at y (y-40)
  SetWindowPos(overlay_hwnd_, HWND_TOPMOST, (int)x - 20, (int)y - 40, 40, 40,
               SWP_SHOWWINDOW | SWP_NOACTIVATE);
  SetTimer(overlay_hwnd_, 1, 30, NULL);
}

void FlutterWindow::HideOverlay() {
  if (overlay_hwnd_) {
    KillTimer(overlay_hwnd_, 1);
    ShowWindow(overlay_hwnd_, SW_HIDE);
  }
}

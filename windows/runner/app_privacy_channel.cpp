#include "app_privacy_channel.h"

#include <flutter/standard_method_codec.h>

#include <variant>

AppPrivacyChannel::AppPrivacyChannel(HWND parent_window,
                                     flutter::BinaryMessenger* messenger)
    : parent_window_(parent_window), messenger_(messenger) {}

AppPrivacyChannel::~AppPrivacyChannel() {
  if (channel_) {
    channel_->SetMethodCallHandler(nullptr);
  }
  if (cover_window_) {
    DestroyWindow(cover_window_);
  }
}

bool AppPrivacyChannel::Initialize() {
  RECT frame;
  if (!GetClientRect(parent_window_, &frame)) {
    return false;
  }

  cover_window_ = CreateWindowEx(
      0, L"STATIC", nullptr, WS_CHILD | SS_BLACKRECT, 0, 0,
      frame.right - frame.left, frame.bottom - frame.top, parent_window_,
      nullptr, GetModuleHandle(nullptr), nullptr);
  if (!cover_window_) {
    return false;
  }

  channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger_, "app_privacy",
          &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    if (call.method_name() != "setPrivacyCoverEnabled") {
      result->NotImplemented();
      return;
    }

    const auto* arguments =
        std::get_if<flutter::EncodableMap>(call.arguments());
    if (!arguments) {
      result->Error("invalid_arguments", "Expected an argument map.");
      return;
    }

    const auto enabled_it =
        arguments->find(flutter::EncodableValue("enabled"));
    if (enabled_it == arguments->end()) {
      result->Error("invalid_arguments", "Missing enabled argument.");
      return;
    }
    const auto* enabled = std::get_if<bool>(&enabled_it->second);
    if (!enabled) {
      result->Error("invalid_arguments", "enabled must be a boolean.");
      return;
    }

    cover_enabled_ = *enabled;
    UpdateCover();
    result->Success();
  });

  return true;
}

void AppPrivacyChannel::SetAppActive(bool active) {
  app_active_ = active;
  UpdateCover();
}

void AppPrivacyChannel::Resize() {
  UpdateCover();
}

void AppPrivacyChannel::UpdateCover() {
  if (!cover_window_) {
    return;
  }

  if (!cover_enabled_ || app_active_) {
    ShowWindow(cover_window_, SW_HIDE);
    return;
  }

  RECT frame;
  if (!GetClientRect(parent_window_, &frame)) {
    return;
  }

  SetWindowPos(cover_window_, HWND_TOP, 0, 0, frame.right - frame.left,
               frame.bottom - frame.top, SWP_NOACTIVATE | SWP_SHOWWINDOW);
  RedrawWindow(cover_window_, nullptr, nullptr,
               RDW_INVALIDATE | RDW_UPDATENOW | RDW_ALLCHILDREN);
}

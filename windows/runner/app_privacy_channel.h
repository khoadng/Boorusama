#ifndef RUNNER_APP_PRIVACY_CHANNEL_H_
#define RUNNER_APP_PRIVACY_CHANNEL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <windows.h>

#include <memory>

class AppPrivacyChannel {
 public:
  AppPrivacyChannel(HWND parent_window, flutter::BinaryMessenger* messenger);
  ~AppPrivacyChannel();

  AppPrivacyChannel(const AppPrivacyChannel&) = delete;
  AppPrivacyChannel& operator=(const AppPrivacyChannel&) = delete;

  bool Initialize();
  void SetAppActive(bool active);
  void Resize();

 private:
  void UpdateCover();

  HWND parent_window_;
  flutter::BinaryMessenger* messenger_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  HWND cover_window_ = nullptr;
  bool cover_enabled_ = false;
  bool app_active_ = true;
};

#endif  // RUNNER_APP_PRIVACY_CHANNEL_H_

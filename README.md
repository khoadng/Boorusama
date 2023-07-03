<p align="center">
 <img align="center" width=100% alt="Boorusama Logo" src="https://user-images.githubusercontent.com/19619099/177544952-1d963e91-5c6d-40d2-b731-bf84b63aa246.png" />
</p>

[![License](https://img.shields.io/badge/license-GPLv3-blue)](https://www.gnu.org/licenses/gpl-3.0) 
[![Discord](https://img.shields.io/discord/817638254571946006?label=&logo=discord&logoColor=ffffff&color=5865F2)](https://discord.gg/tvyYVxjfBr) 
[![codecov](https://codecov.io/gh/khoadng/Boorusama/branch/dev/graph/badge.svg?token=Q1YK0TAUIK)](https://codecov.io/gh/khoadng/Boorusama) 
![test](https://github.com/khoadng/Boorusama/actions/workflows/main.yml/badge.svg?branch=dev)

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.degenk.boorusama">
    <img align="center"  width="140" alt="Boorusama Logo" src="http://i.imgur.com/mtGRPuM.png" />
  </a>
</p>

## 📚 Overview

Boorusama is an unofficial, feature-rich client for [Danbooru](https://github.com/danbooru/danbooru) and other booru based site, built with Flutter.

![Banner_1](./images/banner_2.png)
![Banner_2](./images/banner_1.png)

## 🚀 Features
Boorusama offers a wide range of functionalities including:

- Support for Danbooru-based sites, and some sites based on Gelbooru and Moebooru
- Full tag search capabilities with autocomplete and metatags highlighting
- Ability to save searches
- Options to save, import, export your favorite tags
- Quick and easy image saving
- Bulk download of multiple images
- Exploration of newest, curated, and popular posts
- Voting and commenting functionalities
- Viewing translation notes
- Image pool search, filter, and view
- Tag blacklisting
- Creation and management of multiple favorite groups based on different interests or projects.

## 📥 Installation

### Prerequisites:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/downloads)
- [Firebase](https://firebase.google.com/) project (Optional if you use the `boorusama-foss` branch)
- [FlutterFire](https://firebase.flutter.dev/docs/overview/) (Optional if you use the `boorusama-foss` branch)

### Steps:
1. Clone the repository:
```bash
git clone https://github.com/khoadng/Boorusama.git
cd Boorusama
```
2. Install dependencies and generate boilerplate code:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```
3. Configure Firebase (Skip if you use the `boorusama-foss` branch):
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
4. Connect to an Android device/emulator and run the app:
```bash
flutter run --release
```
Or build an APK and install it manually:
```bash
flutter build apk --release
```

## 🌐 Translation

Help us translate Boorusama to make it more accessible. Here are the steps:

1. Fork this repository
2. Use the English translations as a reference
3. Create a new JSON file in [translation](./assets/translations/) folder using your two-letter [language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
4. [Submit a PR](https://github.com/khoadng/Boorusama/pulls)

|Language|Contributors|Source|
|--------|------------|------|
|English| [@khoadng](https://github.com/khoadng) |[`en-US.json`](./assets/translations/en-US.json)|
|Vietnamese| [@khoadng](https://github.com/khoadng) |[`vi-VN.json`](./assets/translations/vi-VN.json)|
|Japanese| [@khoadng](https://github.com/khoadng) |[`ja-JP.json`](./assets/translations/ja-JP.json)|
|Russian| [@lesh6295-png](https://github.com/lesh6295-png) |[`ru-RU.json`](./assets/translations/ru-RU.json)|
|Belarusian| [@lesh6295-png](https://github.com/lesh6295-png) |[`be-BY.json`](./assets/translations/be-BY.json)|
|German| [@Forsaken5687](https://github.com/Forsaken5687) |[`de-DE.json`](./assets/translations/de-DE.json)|
|Chinese (Traditional)| [@xperiazu21](https://github.com/xperiazu21) |[`zh-TW.json`](./assets/translations/zh-TW.json)|

Alternatively, you can assist with translations on [POEditor](https://poeditor.com/join/project/uNPcakFEut).

## 📝 Feedback & Issues
Feel free to send me feedback on [Discord](https://discord.gg/tvyYVxjfBr) or [file an issue](https://github.com/khoadng/Boorusama/issues/new). Feature requests are always welcome.

## 🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

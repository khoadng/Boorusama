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


## Introduction

Boorusama is one of the most feature-rich unofficial clients for [Danbooru](https://github.com/danbooru/danbooru). Built with Flutter.

![Banner_1](./images/banner_2.png)
![Banner_2](./images/banner_1.png)

## Features
- Fully supported tag search with autocomplete and metatags highlighting
- Quick and easy image saving
- Support download multiple images in bulk
- Explore the newest, curated and popular posts with ease
- View, vote, and add comments
- View translation notes
- Search, filter, and view images pool
- Easily blacklist any tags

## Installation
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Clone or download the repo. Make sure you have [Git](https://git-scm.com/downloads) installed first.
```bash
git clone https://github.com/khoadng/Boorusama.git
cd Boorusama
```
- Install dependencies and generate boilerplates code.
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```
- Connect to an Android device/emulator and run the app.
```bash
flutter run --release
```
or you could build an apk and install it manually.

```bash
flutter build apk --release
```
## Translation
1. Fork this repo
2. Use the existing English translations as a reference.
2. Create a new file JSON in [translation](./assets/translations/) folder with your two-letter [language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
3. [Submit a PR](https://github.com/khoadng/Boorusama/pulls)

Or just send me the JSON file through Discord if you are not familiar with programming.

|Language|Contributors|Source|
|--------|------------|------|
|Vietnamese| [@khoadng](https://github.com/khoadng) |[`vi.json`](./assets/translations/vi.json)|
|Russian| [@lesh6295-png](https://github.com/lesh6295-png) |[`ru.json`](./assets/translations/ru.json)|
|Belarusian| [@lesh6295-png](https://github.com/lesh6295-png) |[`be.json`](./assets/translations/be.json)|

## Feedback
Feel free to send me feedback on [Discord](https://discord.gg/tvyYVxjfBr) or [file an issue](https://github.com/khoadng/Boorusama/issues/new). Feature requests are always welcome.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.



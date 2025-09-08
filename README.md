<p align="center">
 <img align="center" width=100% alt="Boorusama Logo" src="https://user-images.githubusercontent.com/19619099/177544952-1d963e91-5c6d-40d2-b731-bf84b63aa246.png" />
</p>

[![License](https://img.shields.io/badge/license-GPLv3-blue)](https://www.gnu.org/licenses/gpl-3.0) 
[![Discord](https://img.shields.io/discord/817638254571946006?label=&logo=discord&logoColor=ffffff&color=5865F2)](https://discord.gg/tvyYVxjfBr) 

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.degenk.boorusama">
    <img align="center"  width="140" alt="Boorusama Logo" src="http://i.imgur.com/mtGRPuM.png" />
  </a>
</p>

## Overview

Boorusama is an unofficial, cross-platform client for major booru imageboards. It covers all core functionality and gives you total control over your experience with extra features like bulk downloads, favorite tags, advanced blacklisting, and more.

![Banner_1](./images/banner_2.png)  
![Banner_2](./images/banner_1.png)

## Features

Supported imageboards:
- Danbooru
- Gelbooru 0.2.5, Gelbooru 0.1, Gelbooru 0.2
- e621ng
- Zerochan
- Moebooru
- Shimmie2
- Sankaku
- Philomena
- Szurubooru
- Hydrus Network
- Hybooru
- anime-pictures

## Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/downloads)

### Steps
1. Clone the repository:
```bash
git clone https://github.com/khoadng/Boorusama.git
cd Boorusama
```
2. Install dependencies and generate boilerplate code:

**Linux/macOS:**
```bash
flutter pub get
./gen.sh
```

**Windows:**
```powershell
flutter pub get
.\gen.ps1
```

3. Connect to an Android device or emulator and run the app:
```bash
flutter run --release
```
Or build an APK and install it manually:

**Linux/macOS:**
```bash
./build.sh apk --flavor prod
```

**Windows:**
```powershell
.\build.ps1 apk -Flavor prod
```

## Translation

Translations are managed via [Weblate](https://weblate.org/en/).

<a href="https://hosted.weblate.org/engage/boorusama/">
<img src="https://hosted.weblate.org/widget/boorusama/multi-auto.svg" alt="Translation status" />
</a>

## Feedback & Issues
Feel free to send me feedback on [Discord](https://discord.gg/tvyYVxjfBr) or [file an issue](https://github.com/khoadng/Boorusama/issues/new). Feature requests are always welcome.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

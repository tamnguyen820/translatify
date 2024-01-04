# Translatify

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.16.5-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2.3-blue.svg)](https://dart.dev/)

## Description

**Translatify** is a Flutter mobile translation app project. The project integrates: 
1. AWS Translate and Google Translate API for translation and language detection.
2. AWS Polly for text-to-speech generation.
3. AWS Rekognition for image text detection.

## Features

- **Text Translation:** Fast translation in 75 different languages.
- **Language Detection:** Quick language detection to aid users in choosing the language of the source text.
- **Speech Generation:** Sythesize audio in 20+ languages.
- **Image Text Detection**: Detect text within images and overlay source text with translated text. Image can be chosen from the phone's gallery or taken within the app using a camera.

## Demo
https://github.com/tamnguyen820/translatify/assets/66036226/215d5b84-dfe3-470d-8267-0d66ab91a8d5

https://github.com/tamnguyen820/translatify/assets/66036226/92ec083c-e7c5-4e10-948e-2af8f5640ac8

## Installation

If you are not familiar with Flutter and running Android emulators, you should check this out: [Start building Flutter Android apps on Windows](https://docs.flutter.dev/get-started/install/windows/mobile?tab=virtual)

```bash
# Clone the repository
git clone https://github.com/tamnguyen820/translatify.git

# Change directory
cd translatify

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Build
```bash

# Change directory
cd translatify

# Get dependencies
flutter pub get

flutter clean
flutter build apk

# Now, connect your Android device with a USB cable

# Install
flutter install
```

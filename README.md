# Agora Demo — Flutter Video/Audio Calling

Flutter app with 1-to-1 audio & video calling using Agora RTC SDK.

## Features
- Chat UI
- Audio call (mute, speaker toggle)
- Video call (mute, camera off, switch camera)

## Setup
1. `git clone ...`
2. `flutter pub get`
3. Copy `lib/core/constants/app_constant.example.dart` → `app_constant.dart`
4. Add your Agora App ID and temp token from [Agora Console](https://console.agora.io)
5. `flutter run`

## Requirements
- Flutter 3.x
- Android compileSdk 36 / minSdk 24
- Two devices to test a call

## Tech
Flutter · Agora RTC Engine · Firebase (Auth, Firestore) · BLoC · GetIt
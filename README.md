<div align="center">

# 🎵 Mood Music App

### *Your face. Your feeling. Your soundtrack.*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![TFLite](https://img.shields.io/badge/TensorFlow_Lite-RAF--DB-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-purple?style=for-the-badge)]()

<br/>

> **Mood Music App** is an AI-powered mobile application that reads your facial expression in real time and instantly curates a personalized music playlist to match — or elevate — how you feel.

<br/>

---

</div>

## ✨ What It Does

```
📸 Look at your camera
        ↓
🧠 AI detects your emotion (RAF-DB model, 7 classes)
        ↓
🎵 Music starts playing — matched to your mood
        ↓
🔄 Updates dynamically as your mood changes
```

---

## 🎭 Supported Emotions

| Emoji | Emotion | Music Style |
|:---:|:---|:---|
| 😊 | **Happy** | Pop, Dance, Feel-good hits |
| 😢 | **Sad** | Acoustic, Piano, Emotional |
| 😠 | **Angry** | Rock, Metal, Intense beats |
| 😲 | **Surprised** | EDM, Electronic, Party |
| 😐 | **Neutral** | Chill, Lo-fi, Indie |
| 😨 | **Fearful** | Ambient, Classical, Calm |
| 🤢 | **Disgusted** | Blues, Jazz, Soul |

---

## 🚀 Features

<table>
<tr>
<td width="50%">

### 🤖 AI-Powered Detection
- Real-time face detection via **Google ML Kit**
- Emotion classification with **TFLite (RAF-DB)**
- 7 discrete emotion classes
- Confidence scoring & detection history

</td>
<td width="50%">

### 🎵 Multi-Source Music
- **Spotify** integration (OAuth 2.0)
- **YouTube** playback (Data API v3)
- **Local files** support (file picker + library)
- Background audio + **lock screen controls**

</td>
</tr>
<tr>
<td width="50%">

### 🔐 Authentication
- Secure local auth with **SHA-256 hashed PIN**
- **AES-256 encrypted** Hive storage (key in Keystore/Keychain)
- Session persistence with Hive

</td>
<td width="50%">

### 📊 Mood Analytics
- Mood detection history with timestamps
- Confidence trend charts (fl_chart)
- Persistent local storage

</td>
</tr>
</table>

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/          # App colors, mood labels, genre mappings
│   ├── router/             # go_router navigation
│   └── di/                 # GetIt dependency injection
│
└── features/
    ├── auth/               # Login, PIN, secure storage
    ├── home/               # Shell + main navigation
    ├── mood_detection/     # Camera → TFLite → emotion result
    │   ├── data/
    │   │   └── datasources/
    │   │       ├── tflite_emotion_datasource.dart   ← RAF-DB model
    │   │       ├── face_detection_datasource.dart   ← ML Kit
    │   │       └── camera_datasource.dart
    │   ├── domain/         # MoodResult entity, DetectMood usecase
    │   └── presentation/   # BLoC, detection page, overlay UI
    ├── music/              # Spotify / YouTube / Local datasources
    ├── player/             # Audio playback BLoC + player UI
    ├── settings/           # Source selection, preferences
    └── onboarding/         # First-run setup flow
```

**Design Pattern:** Clean Architecture + BLoC

---

## 🧠 How the AI Works

```
Camera Frame (JPEG)
        │
        ▼
┌─────────────────────────┐
│   Google ML Kit         │  Face bounding box detection
│   Face Detection        │  (on-device, hardware accelerated)
└─────────────────────────┘
        │  Cropped face (+ 20% padding)
        ▼
┌─────────────────────────┐
│   Preprocessing         │  Resize → 48×48
│                         │  ImageNet normalization
│                         │  (mean=[0.485,0.456,0.406])
└─────────────────────────┘
        │  Tensor [1, 48, 48, 3]
        ▼
┌─────────────────────────┐
│   RAF-DB TFLite Model   │  7-class emotion classification
│   emotion_model.tflite  │  Auto softmax detection
└─────────────────────────┘
        │  Probabilities [0..1] × 7
        ▼
┌─────────────────────────┐
│   MoodResult            │  Detected emotion + confidence %
│                         │  isReliable if confidence ≥ 35%
└─────────────────────────┘
```

---

## 📦 Tech Stack

| Category | Technology |
|:---|:---|
| **Framework** | Flutter 3.x / Dart 3.3+ |
| **State Management** | flutter_bloc + equatable |
| **Navigation** | go_router |
| **Dependency Injection** | get_it + injectable |
| **AI / ML** | tflite_flutter, google_mlkit_face_detection |
| **ML Model** | RAF-DB (7-class emotion, TFLite) |
| **Music - YouTube** | youtube_player_flutter |
| **Music - Local** | just_audio + audio_session |
| **Music - Spotify** | Spotify Web API + flutter_web_auth_2 |
| **Local Storage** | Hive, SharedPreferences, flutter_secure_storage |
| **Networking** | Dio |
| **Charts** | fl_chart |
| **Animations** | Lottie |
| **Image Processing** | image (Dart) |

---

## 🛠️ Getting Started

### Prerequisites

- Flutter `>=3.3.0`
- Dart `>=3.3.0`
- Android SDK (minSdk 26) or iOS 13+
- A device/emulator with a front-facing camera

### 1. Clone the repo

```bash
git clone https://github.com/your-username/mood_music_app.git
cd mood_music_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up environment variables

Create a `.env` file in the project root:

```env
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
SPOTIFY_REDIRECT_URI=moodmusic://callback
```

### 4. Add the TFLite model

Place your `emotion_model.tflite` (RAF-DB trained) in:
```
assets/models/emotion_model.tflite
```

### 5. Run the app

```bash
flutter run
```

---

## 📱 Permissions Required

| Platform | Permission | Reason |
|:---|:---|:---|
| Android & iOS | **Camera** | Real-time mood detection |
| Android | **READ_MEDIA_AUDIO** | Local music playback |
| Android | **FOREGROUND_SERVICE** | Background audio |
| iOS | **NSMicrophoneUsageDescription** | Required for camera access |
| iOS | **NSAppleMusicUsageDescription** | Music playback |

---

## 🗺️ Roadmap

- [x] Real-time emotion detection (RAF-DB)
- [x] Spotify, YouTube & local music sources
- [x] Mood history with charts
- [x] Background audio playback
- [x] Secure local authentication
- [ ] Mood-based playlist recommendations
- [ ] Cloud sync for mood history
- [ ] Social sharing of mood snapshots
- [ ] Widget support (Android/iOS)
- [ ] Wear OS / watchOS companion

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

```bash
# Fork → Clone → Create feature branch
git checkout -b feature/your-feature-name

# Commit your changes
git commit -m "feat: add awesome feature"

# Push and open a PR
git push origin feature/your-feature-name
```

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ and Flutter

*Because every emotion deserves its own soundtrack.*

</div>

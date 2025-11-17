# MyDiary Flutter

A beautiful cross-platform diary application inspired by the movie "Your Name" (君の名は). This Flutter version supports iOS, Android, Windows, Linux, and macOS.

## Features

### 🎨 Beautiful UI
- **Taki & Mitsuha Themes**: Switch between two beautiful themes inspired by the main characters
- **Gradient Backgrounds**: Stunning gradient backgrounds that match the movie's aesthetic
- **Smooth Animations**: Fluid transitions and animations throughout the app

### 📖 Diary Management
- **Rich Text Entries**: Write detailed diary entries with multiple text blocks
- **Photo Support**: Add photos to your diary entries
- **Mood & Weather Tracking**: Record your mood and weather for each entry
- **Location Services**: Automatically capture or manually enter locations
- **Date & Time Selection**: Flexible date and time picker for entries

### 📝 Memo System
- **Todo Lists**: Create and manage todo lists with checkboxes
- **Multiple Topics**: Organize memos into different topics
- **Drag & Drop**: Reorder memo items easily

### 👥 Contacts Management
- **Contact Profiles**: Store contact information with photos
- **Phone Numbers**: Save and manage phone numbers
- **Topic Organization**: Group contacts by topics

### 🎯 Topic System
- **Custom Topics**: Create custom topics for different categories
- **Color Coding**: Assign unique colors to each topic
- **Type Support**: Support for Diary, Memo, and Contact topics
- **Count Tracking**: Automatic counting of items in each topic

### 🔧 Advanced Features
- **Search Functionality**: Search across all your content
- **Profile Management**: Customize your profile with photo and name
- **Theme Switching**: Easy switching between Taki and Mitsuha themes
- **Data Persistence**: Local SQLite database for reliable data storage
- **Cross-Platform**: Works on iOS, Android, Windows, Linux, and macOS

## Installation

### Prerequisites
- Flutter SDK (3.5.4 or higher)
- Dart SDK
- Platform-specific development tools:
  - **Android**: Android Studio with Android SDK
  - **iOS**: Xcode (macOS only)
  - **Windows**: Visual Studio with C++ tools
  - **Linux**: Linux development libraries
  - **macOS**: Xcode

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mydiary_flutter.git
   cd mydiary_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS (macOS only)
   flutter run -d ios
   
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux
   
   # For macOS
   flutter run -d macos
   
   # For web
   flutter run -d web
   ```

### Building for Release

#### Android APK
```bash
flutter build apk --release
```

#### iOS App (macOS only)
```bash
flutter build ios --release
```

#### Windows Executable
```bash
flutter build windows --release
```

#### Linux Executable
```bash
flutter build linux --release
```

#### macOS App
```bash
flutter build macos --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── topic.dart
│   ├── diary_entry.dart
│   ├── diary_item.dart
│   ├── memo.dart
│   └── contact.dart
├── database/                 # Database management
│   └── database_helper.dart
├── providers/                # State management
│   └── app_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── main_screen.dart
│   ├── diary_screen.dart
│   ├── diary_edit_screen.dart
│   ├── memo_screen.dart
│   ├── contacts_screen.dart
│   ├── contact_edit_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── profile_header.dart
│   ├── topic_card.dart
│   └── add_topic_dialog.dart
├── utils/                    # Utilities
│   └── theme_manager.dart
└── l10n/                     # Localization files
```

## Themes

The app includes two beautiful themes inspired by the main characters:

### Taki Theme (Blue)
- Primary color: Blue (#2196F3)
- Gradient: Blue to Light Blue
- Default username: "Taki"

### Mitsuha Theme (Pink)
- Primary color: Pink (#E91E63)
- Gradient: Pink to Light Pink
- Default username: "Mitsuha"

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Acknowledgments

- Inspired by the beautiful movie "Your Name" (君の名は) by Makoto Shinkai
- Original Android version served as the foundation for this Flutter port
- Flutter team for the amazing cross-platform framework

---

Made with ❤️ and Flutter
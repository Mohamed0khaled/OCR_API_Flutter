# MyOCR - Flutter OCR App

A Flutter application that extracts text from images using OCR (Optical Character Recognition).

## Features

- Pick images from gallery
- Capture photos with camera
- Extract text from images using OCR.space API
- Save extracted text to file
- Cross-platform support (Android, iOS)

## Screenshots

*Coming soon*

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio / Xcode
- An OCR.space API key (free tier available)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Mohamed0khaled/OCR_API_Flutter.git
cd OCR_API_Flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Get your free API key:
   - Visit [OCR.space Free API Key](https://ocr.space/ocrapi/freekey)
   - Enter your email to receive a free API key
   - Replace the API key in `lib/services/api.dart`

4. Run the app:
```bash
flutter run
```

## API Configuration

The app uses [OCR.space API](https://ocr.space/ocrapi) for text recognition.

**Free Tier Includes:**
- 25,000 requests/month
- Support for 25+ languages
- Multiple OCR engines

To use your own API key, update `lib/services/api.dart`:

```dart
static const String _apiKey = 'YOUR_API_KEY_HERE';
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   └── ocr_result.dart    # OCR result model
├── screen/
│   └── home_screen.dart   # Main UI screen
├── services/
│   ├── api.dart           # OCR API service
│   └── image.dart         # Image picking service
└── widgets/               # Reusable widgets
```

## Dependencies

- `image_picker` - Pick images from gallery/camera
- `http` - HTTP requests to OCR API
- `path_provider` - Save files to device
- `permission_handler` - Handle camera/gallery permissions

## Permissions

### Android
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture images for OCR</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images for OCR</string>
```

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Mohamed Khaled - [@Mohamed0khaled](https://github.com/Mohamed0khaled)

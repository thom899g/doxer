# Getting Started with Danish Caller Insight

This guide will help you set up and run the Danish Caller Insight app from the provided codebase.

## 📋 Prerequisites

Before you begin, ensure you have:
- **Flutter SDK 3.24+** installed
- **Dart SDK 3.5+** installed
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- A **Firebase account** (free tier is sufficient)

## 🚀 Quick Start

### 1. Extract and Navigate
```bash
# Extract the provided codebase
cd danish-caller-insight

# Verify Flutter installation
flutter doctor
```

### 2. Install Dependencies
```bash
# Get all required packages
flutter pub get

# Generate code (if needed)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Firebase Setup (Required)

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create Project"
3. Name it "Danish Caller Insight"
4. Enable Google Analytics
5. Create project

#### Add Android App
1. In Firebase Console, click "Add app" → Android
2. Package name: `com.danishcallerinsight.app`
3. App nickname: "Danish Caller Insight"
4. Download `google-services.json`
5. Place in `android/app/` directory

#### Enable Firebase Services
1. **Firestore Database**: Click "Create database" → Start in production mode
2. **Firebase Analytics**: Already enabled during project creation
3. **App Check**: Go to App Check → Android → Play Integrity (for production)

### 4. Run the App

#### Development Mode
```bash
# Run in debug mode
flutter run

# Or specify a device
flutter run -d emulator-5554
```

#### Test Release Build
```bash
# Build release APK
flutter build apk --release

# Install and test
flutter install
```

## 🔧 Configuration

### Environment Variables (Optional)
Create a `.env` file in the project root:
```
FIREBASE_PROJECT_ID=your-project-id
ADMOB_APP_ID=ca-app-pub-xxxxxxxxxxxxxxxx~
```

### Monetization Setup (Optional for Development)

#### Google Play Console
1. Create developer account at [Google Play Console](https://play.google.com/console)
2. Create new app "Danish Caller Insight"
3. Set up in-app product "premium_monthly" with price 29 DKK

#### AdMob (Optional)
1. Create AdMob account
2. Add your app
3. Create ad units
4. Update IDs in `monetization_service.dart`

## 📱 Testing

### Manual Testing
1. **GDPR Flow**: Test onboarding consent screens
2. **Call Detection**: Test with incoming calls (requires phone permissions)
3. **Manual Lookup**: Use FAB to lookup numbers
4. **Settings**: Test privacy controls and data deletion
5. **Premium**: Test upgrade flow (requires Play Console setup)

### Automated Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/lookup_service_test.dart

# Run integration tests
flutter test integration_test
```

## 🏗️ Building for Release

### Using Build Script
```bash
# Make script executable
chmod +x build.sh

# Run build
./build.sh
```

### Manual Build
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release --split-per-abi

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

## 📲 App Permissions

The app requires these permissions (already configured in AndroidManifest.xml):

### Required Permissions
- **READ_PHONE_STATE**: Detect incoming calls
- **CALL_PHONE**: Make calls (for callback features)
- **ANSWER_PHONE_CALLS**: Answer calls (iOS compatibility)
- **CALL_SCREENING**: Screen calls (Android 10+)
- **USE_FULL_SCREEN_INTENT**: Show full-screen notifications
- **READ_CONTACTS**: Check if number is in contacts
- **INTERNET**: API calls and Firebase
- **POST_NOTIFICATIONS**: Show caller info notifications

### Runtime Permissions
The app will request these permissions when needed:
1. Phone permissions (for call detection)
2. Contacts permissions (to check known numbers)
3. Notification permissions (Android 13+)

## 🔒 Privacy Features

### GDPR Compliance
- All phone numbers are SHA-256 hashed
- No personal data stored permanently
- Complete data deletion available
- User consent required for all features

### Testing Privacy Features
1. **Data Export**: Settings → Export Data
2. **Data Deletion**: Settings → Delete All Data
3. **Consent Management**: Settings → Privacy & GDPR

## 🐛 Troubleshooting

### Common Issues

#### "Firebase not initialized"
- Ensure `google-services.json` is in `android/app/`
- Check Firebase project is created
- Verify package name matches

#### "Permission denied"
- Grant all requested permissions
- Check AndroidManifest.xml permissions
- Test on physical device (not emulator)

#### "Build failed"
- Run `flutter clean` then `flutter pub get`
- Check Flutter version (3.24+)
- Verify Android SDK is installed

#### "Call detection not working"
- Test on physical device
- Grant phone permissions
- Check if number is in contacts (app ignores known contacts)

### Debug Mode
Enable debug logging by setting `kDebugMode = true` in main.dart

## 📊 Firebase Console

After setup, monitor these in Firebase Console:
- **Firestore**: Crowdsourced spam data
- **Analytics**: User engagement and events
- **Crashlytics**: Error reports
- **App Check**: Security validation

## 🎯 Next Steps

1. **Test Thoroughly**: Test all features on multiple devices
2. **Configure Production**: Set up production Firebase and AdMob
3. **Google Play Store**: Create app listing and upload
4. **Monitor**: Set up monitoring and analytics
5. **Iterate**: Collect feedback and improve

## 📞 Support

If you encounter issues:
1. Check this guide again
2. Review the README.md
3. Check the LAUNCH_CHECKLIST.md
4. Create an issue in your repository

## 🎉 Success!

Once you have the app running, you'll see:
- GDPR-compliant onboarding
- Clean Material 3 UI
- Call detection working
- Manual lookup functionality
- Privacy controls available

The app is now ready for testing and deployment!
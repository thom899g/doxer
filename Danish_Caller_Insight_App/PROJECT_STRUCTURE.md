# Danish Caller Insight - Project Structure

```
danish-caller-insight/
├── android/                          # Android-specific code
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml    # App permissions and configuration
├── lib/                              # Main Flutter application code
│   ├── core/                         # Core app functionality
│   │   ├── app_theme.dart            # Theme configuration
│   │   ├── router.dart               # Navigation routes
│   │   └── providers.dart            # Global providers
│   ├── features/                     # Feature modules
│   │   ├── call_detection/           # Call detection and handling
│   │   │   ├── services/
│   │   │   │   └── call_detection_service.dart
│   │   │   └── models/
│   │   │       └── call_event.dart
│   │   ├── lookup/                   # Phone number lookup functionality
│   │   │   ├── services/
│   │   │   │   └── lookup_service.dart
│   │   │   ├── models/
│   │   │   │   ├── caller_info.dart
│   │   │   │   └── cvr_response.dart
│   │   │   └── widgets/
│   │   ├── monetization/             # In-app purchases and ads
│   │   │   └── services/
│   │   │       └── monetization_service.dart
│   │   ├── privacy/                  # GDPR and privacy controls
│   │   │   ├── services/
│   │   │   │   └── privacy_service.dart
│   │   │   └── screens/
│   │   │       └── privacy_screen.dart
│   │   ├── home/                     # Home screen and dashboard
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   ├── settings/                 # App settings and preferences
│   │   │   └── screens/
│   │   │       └── settings_screen.dart
│   │   ├── onboarding/               # First-time user onboarding
│   │   │   └── screens/
│   │   │       └── onboarding_screen.dart
│   │   ├── history/                  # Call history and logs
│   │   │   └── services/
│   │   │       └── history_service.dart
│   │   └── manual_lookup/            # Manual number lookup
│   │       └── screens/
│   │           └── manual_lookup_screen.dart
│   ├── utils/                        # Utility functions and classes
│   │   ├── gdpr_utils.dart           # GDPR compliance utilities
│   │   ├── logger.dart               # Logging utility
│   │   └── rate_limiter.dart         # API rate limiting
│   └── main.dart                     # App entry point
├── assets/                           # Static assets
│   ├── images/
│   ├── icons/
│   └── sounds/
├── fonts/                            # Custom fonts
├── test/                             # Test files
├── integration_test/                 # Integration tests
├── pubspec.yaml                      # Flutter dependencies
├── build.sh                          # Build automation script
├── LAUNCH_CHECKLIST.md               # Pre-launch checklist
├── PROJECT_STRUCTURE.md              # This file
└── README.md                         # Project documentation
```

## Key Features Implementation

### 🔒 GDPR Compliance
- **SHA-256 Hashing**: All phone numbers hashed in `gdpr_utils.dart`
- **Consent Management**: Full consent flow in `privacy_service.dart`
- **Data Export**: User data export functionality
- **Right to Deletion**: Complete data deletion workflow

### 📞 Call Detection
- **Android**: Uses `telephony` package with BroadcastReceiver
- **iOS**: `flutter_callkit_incoming` for CallKit integration
- **Auto-blocking**: High spam scores automatically reject calls
- **Real-time UI**: CallKit UI with caller information

### 🔍 Lookup System
- **CVR Integration**: Danish Business Register lookup
- **OpenStreetMap**: Nominatim API for geocoding
- **Crowdsourced Data**: Firestore database for spam reports
- **Rate Limiting**: Prevents API abuse

### 💰 Monetization
- **Freemium Model**: 5 free lookups per day
- **Premium Subscription**: Unlimited lookups, no ads
- **Ad Integration**: Google Mobile Ads for free users
- **In-App Purchases**: Smooth upgrade experience

### 🎨 UI/UX
- **Material 3**: Modern design with Danish color scheme
- **Responsive**: Works on phones and tablets
- **Accessibility**: Supports screen readers and high contrast
- **Localization**: Danish and English support

## Development Workflow

### Setup
1. Clone repository
2. Run `flutter pub get`
3. Configure Firebase (see README)
4. Run `flutter run` to start development

### Building
- Use `./build.sh` for automated build process
- Generates APK, App Bundle, and documentation
- Runs tests automatically

### Testing
- Unit tests: `flutter test`
- Integration tests: `flutter test integration_test`
- Widget tests: Individual widget test files

### Deployment
1. Complete launch checklist
2. Build release version
3. Upload to Google Play Console
4. Monitor Firebase Analytics
5. Respond to user feedback

## Architecture Principles

### Clean Architecture
- Feature-based module structure
- Separation of concerns
- Dependency injection with Riverpod
- Reactive state management

### Security First
- Privacy by design
- GDPR compliance built-in
- Secure data handling
- Encrypted local storage

### Performance
- Background processing for lookups
- Efficient API usage
- Caching strategies
- Optimized for battery life

### Maintainability
- Comprehensive documentation
- Type safety with Dart
- Automated testing
- Code generation where appropriate
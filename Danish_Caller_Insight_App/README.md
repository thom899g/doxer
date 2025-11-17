# Danish Caller Insight (DCI)

A GDPR-compliant mobile app for identifying unknown Danish phone calls using public data sources. Built with Flutter for Android (primary) and iOS (future support).

## 🌟 Features

### Core Functionality
- **Automatic Call Detection**: Identifies incoming calls from unknown numbers
- **GDPR-Safe Lookup**: All phone numbers are SHA-256 hashed before processing
- **Business Identification**: Uses Danish CVR (Business Register) data
- **Location Services**: Integrates with OpenStreetMap for address information
- **Spam Protection**: Crowdsourced spam database with auto-blocking
- **Real-time Notifications**: Shows caller info during incoming calls

### Privacy & Security
- **Zero Data Storage**: No permanent storage of phone numbers
- **GDPR Compliant**: Full compliance with EU data protection regulations
- **Anonymous Processing**: All data is hashed and anonymized
- **User Control**: Complete control over data sharing preferences
- **Right to Deletion**: One-tap data deletion (GDPR Article 17)

### Monetization
- **Freemium Model**: 5 free lookups per day
- **Premium Subscription**: Unlimited lookups, no ads (29 DKK/month)
- **Non-intrusive Ads**: Only for free users, respectful placement

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.24+ with Dart 3.5+
- **State Management**: Riverpod 2.5+
- **Database**: Firestore (for crowdsourced data)
- **Local Storage**: SQLite with SQLCipher for premium users
- **Notifications**: flutter_local_notifications
- **Call Detection**: telephony (Android) + flutter_callkit_incoming (iOS)

### Data Sources
- **CVR API**: Danish Business Register for company information
- **OpenStreetMap**: Nominatim API for geocoding
- **Crowdsourced Database**: User-contributed spam reports (with consent)

### Security Measures
- **SHA-256 Hashing**: All phone numbers hashed before any processing
- **App Check**: Firebase App Check with Play Integrity
- **Rate Limiting**: Prevents API abuse
- **Secure Storage**: Flutter Secure Storage for sensitive data

## 🚀 Getting Started

### Prerequisites
- Flutter 3.24+ SDK
- Dart 3.5+
- Android Studio / Xcode
- Firebase account
- Google Play Console account (for Android)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/danish-caller-insight.git
cd danish-caller-insight
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android app with package name: `com.danishcallerinsight.app`
   - Download `google-services.json` and place in `android/app/`
   - Enable Firestore Database and Firebase Analytics

4. **Run the app**
```bash
flutter run
```

### Building for Release

**Android APK**
```bash
flutter build apk --release --split-per-abi
```

**Android App Bundle (recommended)**
```bash
flutter build appbundle --release
```

## 📱 Usage

### First Time Setup
1. Complete GDPR onboarding
2. Grant necessary permissions (phone, contacts, notifications)
3. Configure privacy preferences
4. Choose data sharing options

### Daily Usage
- App automatically detects incoming calls
- Unknown numbers trigger background lookup
- Caller information appears in notification/CallKit UI
- High spam scores auto-reject calls
- View call history and lookup history

### Manual Lookup
- Use the floating action button to lookup any number
- Enter Danish phone number (with or without +45)
- View detailed caller information
- Report spam if applicable

## 🔧 Configuration

### Environment Variables
Create a `.env` file for sensitive configuration:
```
FIREBASE_PROJECT_ID=your-project-id
ADMOB_APP_ID=your-admob-app-id
```

### API Configuration
Update API endpoints in `lookup_service.dart`:
- CVR API endpoint
- OpenStreetMap Nominatim endpoint
- Set appropriate User-Agent headers

### Monetization Setup
1. Configure in-app purchases in Google Play Console
2. Set up premium product "premium_monthly" (29 DKK)
3. Configure AdMob with your app ID
4. Update ad unit IDs in production

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

### Widget Tests
```bash
flutter test test/widget/
```

### Test Scenarios
- GDPR consent flow
- Call detection and lookup
- Premium upgrade process
- Data export and deletion
- Offline functionality

## 📊 Monitoring

### Firebase Analytics
- App opens and user engagement
- Call lookup success rates
- Premium conversion funnel
- GDPR consent metrics

### Crash Reporting
- Firebase Crashlytics integration
- Error tracking and reporting
- Performance monitoring

### Key Metrics
- Daily Active Users (DAU)
- Call lookup success rate
- Spam detection accuracy
- User retention rates
- GDPR compliance metrics

## 🔒 Privacy & Compliance

### GDPR Features
- ✅ Right to access (data export)
- ✅ Right to rectification
- ✅ Right to erasure (data deletion)
- ✅ Right to data portability
- ✅ Consent management
- ✅ Data minimization
- ✅ Privacy by design

### Data Flow
1. Incoming call detected
2. Phone number SHA-256 hashed
3. Hashed number sent to lookup services
4. Results cached temporarily
5. Original number never stored
6. User can delete all data instantly

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Code Style
- Follow Flutter style guide
- Use meaningful variable names
- Add documentation for public APIs
- Write unit tests for business logic

## 🆘 Support

### Issues
Report bugs and feature requests on GitHub Issues.

### Contact
- Email: support@danishcallerinsight.com
- Privacy: privacy@danishcallerinsight.com

### Documentation
- [API Documentation](docs/api.md)
- [Architecture Overview](docs/architecture.md)
- [GDPR Compliance Guide](docs/gdpr.md)

## 🙏 Acknowledgments

- Danish Business Authority (CVR data)
- OpenStreetMap contributors
- Flutter community
- Danish users providing feedback

---

**Built with ❤️ for Danish privacy**
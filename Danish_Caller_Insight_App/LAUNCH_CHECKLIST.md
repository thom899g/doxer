# Danish Caller Insight - Launch Checklist

## Pre-Launch Setup

### 🔐 Firebase Configuration
- [ ] Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Add Android app with package name: `com.danishcallerinsight.app`
- [ ] Download `google-services.json` and place in `android/app/`
- [ ] Enable Firestore Database
- [ ] Set up App Check with Play Integrity
- [ ] Configure Firestore security rules for crowdsourced data
- [ ] Enable Firebase Analytics

### 📱 Android Setup
- [ ] Update `android/app/build.gradle` with your signing config
- [ ] Configure ProGuard rules for release build
- [ ] Set up Play Console account
- [ ] Create app listing on Google Play Console
- [ ] Upload app bundle (AAB) to Play Console
- [ ] Fill out Data Safety form with GDPR compliance info
- [ ] Submit app for review

### 💰 Monetization Setup
- [ ] Create Google Play Console merchant account
- [ ] Set up in-app product "premium_monthly" (29 DKK)
- [ ] Configure Google AdMob account
- [ ] Create ad units for production
- [ ] Update ad unit IDs in monetization service
- [ ] Test in-app purchase flow
- [ ] Configure UMP consent management

### 🔒 Privacy & Compliance
- [ ] Create privacy policy webpage
- [ ] Set up GDPR consent management
- [ ] Configure data deletion workflow
- [ ] Test data export functionality
- [ ] Verify GDPR compliance with legal counsel
- [ ] Create terms of service
- [ ] Set up DPO contact information

### 🚀 App Configuration
- [ ] Update app name and description
- [ ] Configure app icons and screenshots
- [ ] Test on multiple Android devices
- [ ] Verify call detection functionality
- [ ] Test notification system
- [ ] Validate GDPR hashing implementation
- [ ] Test Firestore integration
- [ ] Verify rate limiting works
- [ ] Test offline functionality

### 📊 Analytics & Monitoring
- [ ] Set up Firebase Analytics events
- [ ] Configure crash reporting
- [ ] Set up performance monitoring
- [ ] Create dashboards for key metrics
- [ ] Test analytics consent flow

### 🧪 Testing
- [ ] Unit tests for core functionality
- [ ] Integration tests for call detection
- [ ] UI/widget tests for all screens
- [ ] Test GDPR compliance scenarios
- [ ] Verify premium upgrade flow
- [ ] Test data export/import
- [ ] Validate spam reporting system
- [ ] Test on Android 13+ (API 33+)

### 🌐 API Integration
- [ ] Verify CVR API integration
- [ ] Test OpenStreetMap Nominatim API
- [ ] Validate rate limiting for external APIs
- [ ] Test offline fallback scenarios
- [ ] Verify API error handling

### 📋 Final Checks
- [ ] All permissions declared in AndroidManifest.xml
- [ ] App targets latest Android API level
- [ ] Release build is optimized and obfuscated
- [ ] All test ads replaced with production IDs
- [ ] Privacy policy URL updated
- [ ] Support email configured
- [ ] App description translated to Danish
- [ ] Screenshots in Danish and English

## Post-Launch Monitoring

### 📈 Week 1
- [ ] Monitor app downloads and reviews
- [ ] Track Firebase Analytics events
- [ ] Monitor crash reports
- [ ] Check GDPR compliance metrics
- [ ] Respond to user feedback

### 🔧 Maintenance
- [ ] Regular security audits
- [ ] Update dependencies monthly
- [ ] Monitor API rate limits
- [ ] Review and update privacy policy
- [ ] Test on new Android versions

### 📊 Success Metrics
- [ ] Daily Active Users (DAU)
- [ ] Call lookup success rate
- [ ] Spam detection accuracy
- [ ] Premium conversion rate
- [ ] User retention (Day 1, Day 7, Day 30)
- [ ] GDPR consent rates
- [ ] App store rating

## Emergency Contacts

### Technical Issues
- Firebase Support: Through Firebase Console
- Google Play Support: Through Play Console
- AdMob Support: Through AdMob Console

### Legal & Compliance
- Data Protection Officer: [Your DPO Contact]
- Legal Counsel: [Your Legal Contact]

---

## Quick Commands

### Build Release APK
```bash
flutter build apk --release --split-per-abi
```

### Build App Bundle
```bash
flutter build appbundle --release
```

### Run Tests
```bash
flutter test
flutter test integration_test
```

### Check Dependencies
```bash
flutter pub outdated
```

### Generate Icons
```bash
flutter pub run flutter_launcher_icons:main
```

---

**Note**: This checklist should be reviewed and updated before each major release. Make sure all items are completed before submitting to Google Play Store.
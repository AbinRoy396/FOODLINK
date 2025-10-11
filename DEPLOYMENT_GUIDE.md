# FoodLink Deployment Guide

## 🚀 Backend Deployment (Node.js API)

### Option 1: Render (Recommended - Free)

1. **Create account** at https://render.com
2. **Connect GitHub** repository
3. **Create New Web Service**
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Environment: Node
4. **Add Environment Variables:**
   ```
   JWT_SECRET=your-secure-random-string-here
   PORT=3000
   ```
5. **Deploy** - Render will auto-deploy on git push

### Option 2: Railway

```bash
# Install Railway CLI
npm install -g railway

# Login
railway login

# Initialize project
railway init

# Add environment variables
railway variables set JWT_SECRET=your-secret-key

# Deploy
railway up
```

### Option 3: Heroku

```bash
# Install Heroku CLI from https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Create app
heroku create foodlink-api

# Set environment variables
heroku config:set JWT_SECRET=your-secret-key

# Deploy
git push heroku main
```

---

## 📱 Flutter App Deployment

### Android APK Build

```bash
cd food_link_app

# Build release APK
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --split-per-abi

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Google Play Store)

```bash
# Build App Bundle
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

### iOS Build (requires Mac)

```bash
# Build iOS app
flutter build ios --release

# Or build IPA for distribution
flutter build ipa
```

---

## 🔧 Pre-Deployment Checklist

### Backend
- [ ] Set strong JWT_SECRET in production
- [ ] Configure CORS for your domain
- [ ] Set up database backups
- [ ] Add error logging (e.g., Sentry)
- [ ] Test all API endpoints

### Flutter App
- [ ] Update API base URL in app to production backend
- [ ] Configure Firebase for production
- [ ] Add Google Maps API key
- [ ] Test on physical devices
- [ ] Update app version in pubspec.yaml
- [ ] Generate app signing key for release

---

## 🔑 Generate App Signing Key (Android)

```bash
# Generate keystore
keytool -genkey -v -keystore foodlink-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias foodlink

# Update android/key.properties:
storePassword=<password>
keyPassword=<password>
keyAlias=foodlink
storeFile=../../foodlink-key.jks
```

---

## 📦 Distribution Options

### Android
1. **Google Play Store** - Official distribution
2. **Direct APK** - Share APK file directly
3. **Firebase App Distribution** - Beta testing
4. **Amazon Appstore** - Alternative marketplace

### iOS
1. **Apple App Store** - Official distribution
2. **TestFlight** - Beta testing

---

## 🌐 Update Backend URL in Flutter App

Before building, update the API endpoint:

```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://your-backend-url.com';
```

---

## 📊 Post-Deployment

1. **Monitor logs** for errors
2. **Set up analytics** (Firebase Analytics)
3. **Enable crash reporting** (Firebase Crashlytics)
4. **Test all features** in production
5. **Prepare rollback plan** if needed

---

## 🆘 Troubleshooting

### Backend won't start
- Check environment variables are set
- Verify Node.js version compatibility
- Check logs for specific errors

### App can't connect to backend
- Verify backend URL is correct
- Check CORS settings
- Ensure backend is running
- Test API endpoints with Postman

### Build fails
- Run `flutter clean`
- Delete `pubspec.lock` and run `flutter pub get`
- Check Flutter/Dart SDK versions
- Verify all dependencies are compatible

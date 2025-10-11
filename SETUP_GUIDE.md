# 🚀 FoodLink Setup Guide

Complete step-by-step guide to set up and run the FoodLink application.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Node.js** (v20 or higher) - [Download](https://nodejs.org/)
- **Flutter SDK** (v3.35.3 or higher) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Git** - [Download](https://git-scm.com/)

### For Mobile Development
- **Android Studio** (for Android) - [Download](https://developer.android.com/studio)
- **Xcode** (for iOS, macOS only) - [Download](https://developer.apple.com/xcode/)

### Verify Installation
```bash
# Check Node.js version
node --version  # Should be v20+

# Check npm version
npm --version

# Check Flutter version
flutter --version  # Should be 3.35.3+

# Check Flutter doctor
flutter doctor
```

---

## 🔧 Backend Setup

### Step 1: Clone the Repository
```bash
git clone https://github.com/AbinRoy396/FoodLink-.git
cd FoodLink
```

### Step 2: Install Backend Dependencies
```bash
npm install
```

This will install:
- express
- cors
- bcryptjs
- jsonwebtoken
- sqlite3
- nodemon (dev dependency)

### Step 3: Configure Environment Variables (Optional)
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env file
# On Windows: notepad .env
# On macOS/Linux: nano .env
```

Set your environment variables:
```env
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-here
```

**Generate a secure JWT secret:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Step 4: Start the Backend Server
```bash
# Production mode
npm start

# Development mode (with auto-reload)
npm run dev
```

You should see:
```
✅ Connected to SQLite database
✅ Database tables initialized
🚀 FoodLink API Server running at http://localhost:3000
📊 Database: C:\Projects\FoodLink\foodlink.db
```

### Step 5: Test the Backend
Open a new terminal and test the API:

```bash
# Test server is running
curl http://localhost:3000

# Test registration
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"test123\",\"name\":\"Test User\",\"role\":\"Donor\",\"address\":\"123 Main St\"}"
```

---

## 📱 Flutter App Setup

### Step 1: Navigate to Flutter App Directory
```bash
cd food_link_app
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

This will install all dependencies from `pubspec.yaml`.

### Step 3: Configure Android Emulator (Optional)

**Option A: Using Android Studio**
1. Open Android Studio
2. Go to Tools → Device Manager
3. Create a new Virtual Device
4. Select a device definition (e.g., Pixel 5)
5. Select a system image (e.g., Android 13)
6. Click Finish

**Option B: Using Command Line**
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>
```

### Step 4: Connect Physical Device (Alternative)

**For Android:**
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect device via USB
4. Accept debugging permission on device

**For iOS (macOS only):**
1. Connect iPhone/iPad via USB
2. Trust the computer on device
3. Open Xcode and register device

### Step 5: Verify Connected Devices
```bash
flutter devices
```

You should see your emulator or physical device listed.

### Step 6: Update API Base URL (If Needed)

If running on a physical device, update the API URL in `lib/services/api_service.dart`:

```dart
// For Android Emulator (default)
static const String baseUrl = "http://10.0.2.2:3000/api";

// For iOS Simulator
static const String baseUrl = "http://localhost:3000/api";

// For Physical Device (replace with your computer's IP)
static const String baseUrl = "http://192.168.1.100:3000/api";
```

**Find your computer's IP:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
```

### Step 7: Run the Flutter App
```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run in release mode (faster)
flutter run --release
```

---

## 🎯 First Time Usage

### 1. Launch the App
The app will show a splash screen, then navigate to the role selection screen.

### 2. Register a New User
1. Select your role (Donor, NGO, or Receiver)
2. Fill in the registration form
3. Click "Register"

### 3. Login
If you already have an account:
1. Click "Already have an account? Sign in"
2. Enter email, password, and select role
3. Click "Login"

### 4. Test Features

**As a Donor:**
- Create a donation
- View your donations
- Track donation status

**As a Receiver:**
- Browse available donations
- Create a food request
- Track request status

**As an NGO:**
- View all donations
- Verify donations
- Allocate donations to receivers

---

## 🔍 Troubleshooting

### Backend Issues

**Problem: Port 3000 already in use**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:3000 | xargs kill -9
```

**Problem: SQLite database locked**
- Stop the server
- Delete `foodlink.db` and `foodlink.db-journal`
- Restart the server

**Problem: Module not found**
```bash
# Delete node_modules and reinstall
rm -rf node_modules
npm install
```

### Flutter Issues

**Problem: Flutter command not found**
```bash
# Add Flutter to PATH
# Windows: Add C:\flutter\bin to System PATH
# macOS/Linux: Add export PATH="$PATH:/path/to/flutter/bin" to ~/.bashrc
```

**Problem: Android licenses not accepted**
```bash
flutter doctor --android-licenses
```

**Problem: CocoaPods not installed (iOS)**
```bash
sudo gem install cocoapods
cd ios
pod install
```

**Problem: Build failed**
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

**Problem: Hot reload not working**
- Press 'r' in terminal for hot reload
- Press 'R' for hot restart
- Or stop and run again

### Network Issues

**Problem: Cannot connect to backend from emulator**
- Ensure backend is running on port 3000
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For iOS simulator, use `localhost`
- For physical device, use your computer's IP address

**Problem: CORS errors**
- Backend already has CORS enabled for all origins
- Check if backend is running
- Verify API URL in `api_service.dart`

---

## 📊 Database Management

### View Database Contents
```bash
# Install SQLite CLI (if not installed)
# Windows: Download from https://www.sqlite.org/download.html
# macOS: brew install sqlite
# Linux: sudo apt-get install sqlite3

# Open database
sqlite3 foodlink.db

# View tables
.tables

# View users
SELECT * FROM users;

# View donations
SELECT * FROM donations;

# View requests
SELECT * FROM requests;

# Exit
.quit
```

### Reset Database
```bash
# Stop the server
# Delete the database file
rm foodlink.db

# Restart the server (it will recreate the database)
npm start
```

---

## 🧪 Testing

### Backend Testing
```bash
# Run tests (when implemented)
npm test

# Manual API testing with curl
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{"email":"donor@test.com","password":"test123","name":"Test Donor","role":"Donor","address":"123 Main St"}'
```

### Flutter Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

---

## 🚀 Production Deployment

### Backend Deployment
1. Set environment variables:
   ```env
   PORT=3000
   JWT_SECRET=<secure-random-string>
   NODE_ENV=production
   ```

2. Use a process manager:
   ```bash
   npm install -g pm2
   pm2 start server.js --name foodlink-api
   pm2 save
   pm2 startup
   ```

### Flutter App Deployment

**Android:**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

**iOS:**
```bash
# Build for iOS
flutter build ios --release
```

---

## 📞 Getting Help

If you encounter issues:

1. Check this guide thoroughly
2. Review the main [README.md](README.md)
3. Check [CHANGELOG.md](CHANGELOG.md) for recent changes
4. Open an issue on [GitHub](https://github.com/AbinRoy396/FoodLink-/issues)

---

## ✅ Setup Checklist

- [ ] Node.js installed and verified
- [ ] Flutter SDK installed and verified
- [ ] Repository cloned
- [ ] Backend dependencies installed
- [ ] Backend server running successfully
- [ ] Flutter dependencies installed
- [ ] Emulator/device connected
- [ ] Flutter app running successfully
- [ ] Test user registered
- [ ] Basic features tested

---

**Congratulations! 🎉 Your FoodLink application is now set up and running!**

Start making a difference by connecting food donors with those in need! 🍽️❤️

# 🗺️ Google Maps API Setup Guide

**Issue**: App crashes with "API key not found" error

**Solution**: Add Google Maps API key to AndroidManifest.xml

---

## 🚀 Quick Fix (For Testing)

### Option 1: Use Without Maps (Temporary)

If you want to test the app without maps immediately, comment out the map tabs:

**In each dashboard file, comment out the Map tab:**

```dart
// Temporarily disable map tab
// const DonorMapTab(),
```

Then remove the Map tab from bottom navigation items.

---

## 🔑 Option 2: Get Google Maps API Key (Recommended)

### Step 1: Get API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Maps SDK for Android**
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Copy the API key

### Step 2: Add API Key to Android

Open: `android/app/src/main/AndroidManifest.xml`

Find this line (already added):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

Replace `YOUR_API_KEY_HERE` with your actual API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyD...your-actual-key"/>
```

### Step 3: Add API Key to iOS (Optional)

Open: `ios/Runner/AppDelegate.swift`

Add this line in the `application` function:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

---

## 🎯 Quick Test Without Maps

### Modify Dashboards to Remove Map Tab:

**For Donor (`improved_dashboards.dart`):**
```dart
_pages = [
  const DonorHomeTab(),
  const DonorDonationsTab(),
  // const DonorMapTab(),  // Commented out
  const DonorProfileTab(),
];
```

**Update bottom navigation items (remove Map):**
```dart
items: const [
  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism_outlined), label: 'Donations'),
  // Remove Map item
  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
],
```

Do the same for NGO and Receiver dashboards.

---

## ✅ After Adding API Key

1. **Clean the build:**
```bash
flutter clean
```

2. **Get dependencies:**
```bash
flutter pub get
```

3. **Rebuild and run:**
```bash
flutter run
```

---

## 🔒 Security Best Practices

### Restrict API Key:

1. In Google Cloud Console, click on your API key
2. Under **Application restrictions**, select **Android apps**
3. Add your package name: `com.example.food_link_app`
4. Add SHA-1 certificate fingerprint

### Get SHA-1 fingerprint:
```bash
# For debug key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## 💡 Alternative: Use Mock Map

If you don't want to use Google Maps, you can replace the MapViewScreen with a simple placeholder:

```dart
class MapViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Map feature coming soon!'),
          Text('Google Maps API key required'),
        ],
      ),
    );
  }
}
```

---

## 🎉 Summary

**Current Status:**
- ✅ API key placeholder added to AndroidManifest.xml
- ⚠️ Need to replace with actual API key

**To Fix Immediately:**
1. Get Google Maps API key (free tier available)
2. Replace `YOUR_API_KEY_HERE` in AndroidManifest.xml
3. Run `flutter clean && flutter run`

**Or Test Without Maps:**
1. Comment out map tabs in dashboard files
2. Remove map items from bottom navigation
3. Run the app

---

**The app will work perfectly once you add the API key!** 🚀

# 🗺️ How to Get Google Maps API Key (5 Minutes)

## Step-by-Step Guide

### 1. Go to Google Cloud Console
Open: https://console.cloud.google.com/

### 2. Create a New Project
- Click "Select a project" at the top
- Click "NEW PROJECT"
- Name it: "FoodLink"
- Click "CREATE"

### 3. Enable Maps SDK for Android
- In the search bar, type: "Maps SDK for Android"
- Click on "Maps SDK for Android"
- Click "ENABLE"

### 4. Create API Key
- Go to "Credentials" (left sidebar)
- Click "CREATE CREDENTIALS"
- Select "API Key"
- **Copy the API key** (it looks like: AIzaSyD...)

### 5. Add API Key to Your App

Open: `android/app/src/main/AndroidManifest.xml`

Find this line (around line 46):
```xml
android:value="AIzaSyBkDxF8qZ9X7Y6vW5tU4sR3qP2oN1mL0kJ"/>
```

Replace with your actual key:
```xml
android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### 6. Rebuild the App
```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ That's It!

The map will now work in:
- ✅ Donor Dashboard (Map tab)
- ✅ NGO Dashboard (Map tab)
- ✅ Receiver Dashboard (Map tab)
- ✅ Admin Dashboard (if map is added)

---

## 🔒 Optional: Restrict API Key (Recommended for Production)

1. In Google Cloud Console, click on your API key
2. Under "Application restrictions":
   - Select "Android apps"
   - Click "ADD AN ITEM"
   - Package name: `com.example.food_link_app`
   - Get SHA-1 fingerprint:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Copy the SHA-1 and paste it

3. Under "API restrictions":
   - Select "Restrict key"
   - Check "Maps SDK for Android"
   - Click "SAVE"

---

## 💡 Free Tier

Google Maps offers:
- ✅ $200 free credit per month
- ✅ Enough for development and testing
- ✅ No credit card required initially

---

## 🚨 Troubleshooting

### Map shows gray screen?
- Check if API key is correct
- Make sure "Maps SDK for Android" is enabled
- Run `flutter clean` and rebuild

### "API key not found" error?
- Check AndroidManifest.xml has the meta-data tag
- Make sure the key is inside `<application>` tag
- Rebuild the app

### Map loads but no markers?
- Check if donations exist in database
- Check API endpoint is working
- Check console for errors

---

## 🎉 Done!

Once you add the API key, all maps will work perfectly! 🗺️

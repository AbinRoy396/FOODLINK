# 📱 Connect Android Device Instructions

## ⚠️ Device Not Authorized

Your device **RZ8W90S79KP** is detected but not authorized for USB debugging.

---

## ✅ Steps to Authorize Your Device

### 1. **Check Your Phone Screen**
   - Look for a popup dialog asking "Allow USB debugging?"
   - The dialog shows your computer's RSA fingerprint
   - **Tap "Allow"** or "OK"

### 2. **If No Dialog Appears:**
   
   **Option A: Revoke and Retry**
   - On your phone, go to: **Settings** → **Developer Options**
   - Find **"Revoke USB debugging authorizations"**
   - Tap it
   - Unplug and replug your USB cable
   - The authorization dialog should appear again

   **Option B: Check USB Settings**
   - When you plug in the USB cable, swipe down notification panel
   - Tap on "USB for file transfer" notification
   - Select **"File Transfer"** or **"PTP"** mode (not "Charging only")

### 3. **Enable Developer Options** (if not already enabled)
   - Go to **Settings** → **About Phone**
   - Find **"Build Number"**
   - Tap it **7 times** rapidly
   - You'll see "You are now a developer!"
   - Go back to Settings → **Developer Options**
   - Enable **"USB Debugging"**

### 4. **Check USB Cable**
   - Use the original cable that came with your phone
   - Some cables are charge-only and don't support data transfer

---

## 🔄 After Authorization

Once you tap "Allow" on your phone, run:

```bash
flutter devices
```

You should see your device listed as:
```
RZ8W90S79KP (mobile) • RZ8W90S79KP • android-arm64 • Android X.X (API XX)
```

Then run the app:

```bash
flutter run -d RZ8W90S79KP
```

Or simply:

```bash
flutter run
```

Flutter will automatically select your physical device over the emulator.

---

## 🐛 Troubleshooting

### Device Still Not Showing?

1. **Restart ADB:**
   ```bash
   flutter doctor --android-licenses
   adb kill-server
   adb start-server
   flutter devices
   ```

2. **Check USB Drivers (Windows):**
   - Install your phone manufacturer's USB drivers
   - Common manufacturers:
     - Samsung: Samsung USB Driver
     - Xiaomi: Mi USB Driver
     - OnePlus: OnePlus USB Drivers
     - Realme: Realme USB Drivers

3. **Try Different USB Port:**
   - Use a USB 2.0 port instead of USB 3.0
   - Try a different USB port on your computer

4. **Restart Both Devices:**
   - Restart your phone
   - Restart your computer
   - Reconnect the USB cable

---

## ✅ Quick Checklist

- [ ] USB Debugging enabled in Developer Options
- [ ] USB cable supports data transfer (not charge-only)
- [ ] USB mode set to "File Transfer" or "PTP"
- [ ] Authorization dialog accepted on phone
- [ ] Phone is unlocked when connecting
- [ ] USB drivers installed (if on Windows)

---

## 🚀 Running on Physical Device

**Advantages of Physical Device:**
- ✅ Real GPS location
- ✅ Faster performance
- ✅ Real camera access
- ✅ Actual network conditions
- ✅ True user experience
- ✅ Battery usage testing

**Command to Run:**
```bash
# Run on specific device
flutter run -d RZ8W90S79KP

# Run on any connected device (auto-select)
flutter run

# Run in release mode (faster)
flutter run --release

# Run with hot reload enabled
flutter run --hot
```

---

## 📝 Current Status

**Detected Devices:**
- ✅ Emulator: `sdk gphone64 x86 64` (emulator-5554)
- ⚠️ Physical Device: `RZ8W90S79KP` (NOT AUTHORIZED)
- ✅ Windows Desktop
- ✅ Chrome Browser
- ✅ Edge Browser

**Next Step:** Authorize USB debugging on your phone!

---

**Once authorized, the app will run on your physical device with all features working!**

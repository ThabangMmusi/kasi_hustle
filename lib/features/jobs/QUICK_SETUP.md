# 🚀 Quick Setup - Job Direction Feature

## ⚡ 5-Minute Setup

Follow these steps to get the Job Direction modal working:

---

### **Step 1: Get Google Maps API Key** (2 minutes)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Navigate to: **APIs & Services** → **Library**
4. Search and enable: **"Maps SDK for Android"**
5. Go to: **APIs & Services** → **Credentials**
6. Click **"Create Credentials"** → **"API Key"**
7. Copy your API key (starts with `AIza...`)

**⚠️ Important**: Enable billing (free tier: $200/month credit)

---

### **Step 2: Add API Key to Android** (1 minute)

Open: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_API_KEY_HERE"/>
```

**Replace** `YOUR_API_KEY_HERE` with your actual key!

---

### **Step 3: Add Permissions** (1 minute)

In same file (`AndroidManifest.xml`), add **outside** `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Full example:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  
  <!-- Add these permissions here -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.INTERNET" />
  
  <application
    android:label="kasi_hustle"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Add API key here -->
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_API_KEY_HERE"/>
    
    <!-- Rest of your app config... -->
    
  </application>
</manifest>
```

---

### **Step 4: Test It!** (1 minute)

1. **Run the demo screen**:

```dart
// Add to your main.dart or any screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => JobDirectionDemoScreen(),
  ),
);
```

Or manually import and call:

```dart
import 'package:kasi_hustle/features/jobs/presentation/screens/job_direction_demo_screen.dart';

// Then navigate to it
```

2. **Or test with existing job**:

```dart
import 'package:kasi_hustle/features/jobs/presentation/widgets/job_direction_bottom_sheet.dart';

// Somewhere in your code where you have a Job object:
JobDirectionBottomSheet.show(context, job);
```

3. **Tap any job** → See the direction modal!

---

## ✅ Verification Checklist

After setup, verify:

- [ ] API key added to `AndroidManifest.xml`
- [ ] Permissions added to `AndroidManifest.xml`
- [ ] App builds without errors: `flutter run`
- [ ] Map loads (not gray screen)
- [ ] Permission dialog appears on first use
- [ ] User location marker shows (blue)
- [ ] Job location marker shows (red)
- [ ] Distance and time display correctly
- [ ] "Open in Google Maps" button works

---

## 🐛 Common Issues & Quick Fixes

### **Issue: Gray map screen**
```
✅ Fix: 
1. Verify API key is correct
2. Check billing is enabled in Google Cloud
3. Make sure "Maps SDK for Android" is enabled
```

### **Issue: "Invalid API key"**
```
✅ Fix:
1. Double-check key in AndroidManifest.xml
2. No spaces or quotes around the key
3. Key should start with "AIza..."
```

### **Issue: No location permission dialog**
```
✅ Fix:
1. Add permissions to AndroidManifest.xml
2. Clean rebuild: flutter clean && flutter run
3. Test on real device (not emulator)
```

### **Issue: User location not showing**
```
✅ Fix:
1. Enable GPS on device
2. Grant location permission when prompted
3. Test outdoors or by window (GPS needs signal)
```

### **Issue: App crashes on map load**
```
✅ Fix:
1. Check logs: flutter run --verbose
2. Verify google_maps_flutter is in pubspec.yaml
3. Try: flutter pub get
```

---

## 🧪 Test Cases

### **Test 1: Basic Map Display**
```
1. Open direction modal
2. Map should load within 2 seconds
3. Job location marker (red) should appear
```

### **Test 2: Location Permission**
```
1. First time opening modal
2. Permission dialog should appear
3. After allowing: blue marker appears
4. Distance and time display
```

### **Test 3: Navigation**
```
1. Tap "Open in Google Maps"
2. Google Maps app should open
3. Destination should be set to job location
4. "Start" button should be visible
```

### **Test 4: Error Handling**
```
1. Deny location permission
2. Error message should display
3. Map still shows job location
4. "Open in Google Maps" still works
```

---

## 📱 Device Testing

### **Recommended Test Devices**
- ✅ Real Android phone (preferred)
- ✅ Android emulator (may have GPS issues)
- ❌ iOS (not configured yet, but can be)

### **Enable GPS on Emulator**
```
1. Open emulator Extended Controls (...)
2. Go to "Location"
3. Enter coordinates manually
4. OR use "Route" playback
```

---

## 🎯 Next Steps

After successful setup:

1. **Integrate into your app**:
   - Add to job details screen
   - Add to job cards
   - Add to applications screen

2. **Customize**:
   - Change marker colors
   - Adjust zoom levels
   - Customize button text

3. **Enhance**:
   - Add distance sorting
   - Show nearby jobs
   - Cache user location

---

## 📞 Need Help?

### **Check Documentation**:
1. `README.md` - Overview & quick reference
2. `INTEGRATION_GUIDE.md` - Detailed instructions
3. `FILE_STRUCTURE.md` - File organization

### **Check Code Examples**:
1. `job_direction_demo_screen.dart` - Working example
2. `job_card_with_directions.dart` - Integration pattern

### **Debug Tips**:
```bash
# View detailed logs
flutter run --verbose

# Clean build
flutter clean
flutter pub get
flutter run

# Check for errors
flutter analyze
```

---

## 💡 Quick Commands

```bash
# Run app
flutter run

# Run with logs
flutter run --verbose

# Hot reload
r (in terminal)

# Hot restart
R (in terminal)

# Clean build
flutter clean && flutter run

# Check packages
flutter pub get
```

---

## ✨ You're Ready!

Setup complete! Now you can:

```dart
// Import
import 'package:kasi_hustle/features/jobs/presentation/widgets/job_direction_bottom_sheet.dart';

// Use anywhere
JobDirectionBottomSheet.show(context, job);
```

**That's it! Enjoy your new direction feature! 🎉**

---

## 📊 Setup Summary

| Step | Time | Status |
|------|------|--------|
| Get API Key | 2 min | ⬜ |
| Add to Manifest | 1 min | ⬜ |
| Add Permissions | 1 min | ⬜ |
| Test | 1 min | ⬜ |
| **Total** | **5 min** | |

**Mark each step as complete (✅) as you go!**

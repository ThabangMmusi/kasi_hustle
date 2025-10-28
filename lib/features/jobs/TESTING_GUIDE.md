# 🧪 Testing the Job Direction Feature

## ✅ Setup Complete!

Your job direction feature is now ready to test! I've added a demo route to your app.

---

## 🚀 **3 Ways to Test**

### **Method 1: Navigate from Code** (Easiest!)

Add this button **anywhere** in your app (like profile screen or home screen):

```dart
// Add this import at the top
import 'package:go_router/go_router.dart';

// Then add this button anywhere:
ElevatedButton(
  onPressed: () => context.go('/job-direction-demo'),
  child: Text('🗺️ Test Job Directions'),
)
```

**OR use IconButton**:
```dart
IconButton(
  icon: Icon(Icons.navigation),
  onPressed: () => context.go('/job-direction-demo'),
  tooltip: 'Test Directions',
)
```

---

### **Method 2: Add to Profile Screen**

Quick edit to `lib/features/profile/presentation/screens/profile_screen.dart`:

Add this button in the body:

```dart
// Find a good place in the profile screen and add:
ListTile(
  leading: Icon(Icons.map),
  title: Text('Test Job Directions'),
  subtitle: Text('Demo with sample jobs'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () => context.go('/job-direction-demo'),
)
```

---

### **Method 3: Direct Navigation from Debug Console**

While app is running, use the debug console to navigate:

```dart
// In your Flutter DevTools or hot reload console
context.go('/job-direction-demo');
```

---

## 📱 **Testing Steps**

### **Before Running:**

1. **Add Google Maps API Key** (Required!)
   - Edit: `android/app/src/main/AndroidManifest.xml`
   - Add inside `<application>`:
   ```xml
   <meta-data
     android:name="com.google.android.geo.API_KEY"
     android:value="YOUR_API_KEY_HERE"/>
   ```

2. **Verify Permissions** (Should already be there)
   - In same file, outside `<application>`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

### **Run the App:**

```bash
flutter run
```

### **Navigate to Demo:**

Use one of the 3 methods above to go to `/job-direction-demo`

---

## 🎯 **What to Test**

The demo screen shows **4 sample jobs** in South Africa:

1. **Johannesburg** - Web Development Project
2. **Pretoria** - Mobile App Design
3. **Cape Town** - Database Optimization
4. **Durban** - API Development

### **Test Checklist:**

- [ ] **Map loads** (not gray screen)
- [ ] **Job marker** appears (red pin)
- [ ] **Permission dialog** appears first time
- [ ] **User location** shows (blue pin after allowing)
- [ ] **Distance & time** display correctly
- [ ] **Route line** connects markers (blue line)
- [ ] **"Open in Google Maps"** button works
- [ ] **Close button** dismisses modal

---

## 🐛 **Troubleshooting**

### **Gray Map Screen?**
```bash
# Check API key is in AndroidManifest.xml
# Make sure billing is enabled in Google Cloud Console
# Verify "Maps SDK for Android" is enabled
```

### **No Permission Dialog?**
```bash
# Add permissions to AndroidManifest.xml
# Clean and rebuild:
flutter clean
flutter run
```

### **Can't Navigate to Demo?**
```bash
# Verify you're logged in (route requires auth)
# Try this from an authenticated screen
# Check terminal for routing errors
```

---

## 💡 **Quick Test Button Code**

Copy-paste this **anywhere** in your app for instant testing:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Add this widget anywhere:
FloatingActionButton(
  onPressed: () => context.go('/job-direction-demo'),
  child: Icon(Icons.navigation),
  tooltip: 'Test Directions',
)
```

---

## 🎬 **Testing with Real Job**

Want to test with your actual job data? Add this to any screen where you have a Job object:

```dart
import 'package:kasi_hustle/features/jobs/presentation/widgets/job_direction_bottom_sheet.dart';

// Then call:
JobDirectionBottomSheet.show(context, yourJobObject);
```

---

## 📊 **Expected Behavior**

1. **Tap job card** → Modal opens
2. **Map loads** → Shows job location
3. **Permission requested** → Tap "Allow"
4. **User location appears** → Blue marker
5. **Distance calculated** → Shows "X km"
6. **Time estimated** → Shows "Y min"
7. **Route drawn** → Blue line
8. **Tap "Open in Google Maps"** → External app opens
9. **Tap "Close"** → Modal dismisses

---

## 🚀 **Production Integration**

After testing, integrate into your app:

### **Add to Job Cards:**
```dart
// In your job card widget:
IconButton(
  icon: Icon(Ionicons.navigate),
  onPressed: () => JobDirectionBottomSheet.show(context, job),
)
```

### **Add to Job Details:**
```dart
// In job_details_bottom_sheet.dart:
OutlinedButton.icon(
  onPressed: () {
    Navigator.pop(context); // Close details
    JobDirectionBottomSheet.show(context, widget.job);
  },
  icon: Icon(Ionicons.navigate_outline),
  label: Text('Get Directions'),
)
```

---

## ✅ **Ready to Test!**

Run your app and navigate to: **`/job-direction-demo`**

**Have fun testing! 🎉**

---

## 📞 **Quick Commands**

```bash
# Run app
flutter run

# Hot reload (after adding test button)
r

# Clean build if issues
flutter clean && flutter run

# View logs
flutter run --verbose
```

---

**Questions?** Check `QUICK_SETUP.md` for detailed setup instructions!

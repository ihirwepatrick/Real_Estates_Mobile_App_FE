# Play Store packaging — Easy Homes

## Application ID

- Android `applicationId` / namespace: `com.easyhomes.app`
- Display name: **Easy Homes**

## 1. Create an upload keystore

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Place `upload-keystore.jks` outside git (or under `android/` and ignore it).

Create `android/key.properties` (gitignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

`android/app/build.gradle` already loads this file for release signing when present.

## 2. Build the App Bundle

```bash
flutter pub get
flutter build appbundle --release --dart-define=API_BASE_URL=https://YOUR_RENDER_URL.onrender.com
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## 3. Google Play Console checklist

- [ ] Create app "Easy Homes" (or update listing)
- [ ] Upload AAB to an internal / closed testing track first
- [ ] Privacy policy URL (required)
- [ ] Store listing: short/full description, screenshots (phone), feature graphic
- [ ] Content rating questionnaire
- [ ] Target audience / data safety form (favorites are local; accounts are for owners)
- [ ] Confirm package name `com.easyhomes.app` is available

## Notes

- Without `key.properties`, release builds still use **debug** signing (fine for local testing, not for Play).
- For production, turn off cleartext HTTP (`usesCleartextTraffic`) once you only use HTTPS Render URL.
- Replace default launcher icon with branded assets when ready (`flutter_launcher_icons` recommended).

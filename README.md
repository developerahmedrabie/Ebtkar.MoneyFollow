# Ebtkar.MoneyFollow

Flutter mobile app (Android / iOS).

Repository: https://github.com/developerahmedrabie/Ebtkar.MoneyFollow

## Repository layout

| Folder | Contents |
|---|---|
| `src/` | Flutter app (`money_follow`, package ID `com.ebtkar.money_follow`) |
| `prototype/` | UI/UX prototype |

Run all `flutter` commands from inside `src/`.

## APK distribution

Upload built APKs to this Google Drive folder:

https://drive.google.com/drive/folders/1ACD05tHuRpZm7vtof9eVlzvwaW3EfOZo?usp=sharing

Build a release APK with:

```powershell
cd src
flutter build apk --release
# output: src\build\app\outputs\flutter-apk\app-release.apk
```

## Development environment (installed 2026-11-13)

Everything lives on drive **D:**. Nothing is installed under `C:\Users\...`.

| Component | Location | Version |
|---|---|---|
| Flutter SDK (git clone, `stable` channel) | `D:\flutter` | Flutter 3.50.0 / Dart 3.14.0 |
| Android SDK | `D:\Android\Sdk` | platform android-36, build-tools 36.0.0 |
| Android SDK packages | `platform-tools`, `emulator`, `cmdline-tools\latest` | |
| JDK (Eclipse Temurin) | `D:\Android\jdk-17` | 17.0.21 |
| Emulators (AVDs) | `D:\Android\avd` | |
| Android user config (`.android`) | `D:\Android\.android` | |
| Gradle cache | `D:\Android\.gradle` | |
| Dart pub cache | `D:\pub-cache` | |

### User environment variables

```
ANDROID_HOME      = D:\Android\Sdk
ANDROID_SDK_ROOT  = D:\Android\Sdk
ANDROID_AVD_HOME  = D:\Android\avd
ANDROID_USER_HOME = D:\Android\.android
JAVA_HOME         = D:\Android\jdk-17
GRADLE_USER_HOME  = D:\Android\.gradle
PUB_CACHE         = D:\pub-cache
```

Added to user `PATH`:

```
D:\flutter\bin
D:\pub-cache\bin
D:\Android\jdk-17\bin
D:\Android\Sdk\cmdline-tools\latest\bin
D:\Android\Sdk\platform-tools
D:\Android\Sdk\emulator
```

Flutter is also configured explicitly:

```powershell
flutter config --android-sdk D:\Android\Sdk --jdk-dir D:\Android\jdk-17
```

### AVG Antivirus note

AVG Web Shield inspects HTTPS traffic, and Java does not trust AVG's certificate by default, so
`sdkmanager` and Gradle downloads fail with `PKIX path building failed`. To fix this, the
**AVG Web/Mail Shield Root** certificate was imported into the JDK trust store
(`D:\Android\jdk-17\lib\security\cacerts`, alias `avg-web-shield-root`).

If you reinstall or upgrade the JDK, re-import the certificate:

```powershell
$root = Get-ChildItem Cert:\LocalMachine\Root, Cert:\CurrentUser\Root |
  ? Subject -like '*AVG Web/Mail Shield Root*' | Select -First 1
[IO.File]::WriteAllBytes("$env:TEMP\avg-root.cer", $root.Export('Cert'))
keytool -importcert -noprompt -trustcacerts -alias avg-web-shield-root `
  -file "$env:TEMP\avg-root.cer" -cacerts -storepass changeit
```

## Emulators

Because `ANDROID_AVD_HOME` points to `D:\Android\avd`, new emulators are stored on D: automatically.

```powershell
# 1. Download a system image (~1.5 GB)
sdkmanager "system-images;android-36;google_apis_playstore;x86_64"

# 2. Create the emulator
avdmanager create avd -n Pixel_API_36 -k "system-images;android-36;google_apis_playstore;x86_64" -d pixel_8

# 3. Run it
flutter emulators --launch Pixel_API_36
```

## Useful commands

```powershell
flutter doctor -v            # verify the setup
cd src                       # project commands run from src/
flutter devices              # list connected devices/emulators
flutter run                  # run on a device/emulator
flutter upgrade              # update Flutter (stable channel)
```

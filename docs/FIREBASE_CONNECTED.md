# SwipeBuy V1 Secure — Firebase Android Connection

Connected Firebase project:

- Project ID: `swipebuy-worldwide`
- Android package: `com.swipebuy.worldwide`
- Android Firebase App ID: `1:928931500188:android:ebcf882096f27d305a1d59`
- Storage bucket: `swipebuy-worldwide.firebasestorage.app`

The supplied `google-services.json` is installed at `android/app/google-services.json`.

## Before running

1. Install Flutter and Android Studio.
2. From the project root run `flutter pub get`.
3. Run `flutterfire configure` if you want to add Web/iOS/macOS/Windows Firebase configurations. Do not overwrite the Android registration with a different Firebase project.
4. For local Android development, App Check may need the Firebase App Check debug provider. Do not ship a debug App Check token in release builds.
5. Add your release SHA-1/SHA-256 fingerprints in Firebase Console before enabling Google Sign-In, phone auth, or production App Check flows that require them.

## Security note

`google-services.json` contains Firebase client configuration. It is not a replacement for server secrets. Keep payment-provider secret keys, service-account private keys, webhook signing secrets, and other credentials out of the Flutter project.

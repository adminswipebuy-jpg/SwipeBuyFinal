# SwipeBuy Android signing

Package ID: `com.swipebuy.worldwide`

Create an upload keystore on your build computer:

    keytool -genkeypair -v -keystore swipebuy-upload.jks -alias swipebuy -keyalg RSA -keysize 2048 -validity 10000

Place it at `android/keystore/swipebuy-upload.jks`, copy `key.properties.example` to `android/key.properties`, and enter the real passwords.

Generate fingerprints:

    cd android
    ./gradlew signingReport

Windows:

    cd android
    gradlew signingReport

Record the `SHA1` and `SHA-256` values for debug and release. Add the appropriate fingerprints in Firebase Console -> Project settings -> General -> SwipeBuy Android -> SHA certificate fingerprints.

If Google Play App Signing is used, also register the relevant Play app-signing certificate fingerprint in Firebase.

Never send the keystore or passwords. The SHA fingerprints can be registered in Firebase.

After SHA registration, Google Sign-In and Phone Authentication can be configured.

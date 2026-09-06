# Firebase Android configuration

Firebase project: `swipebuy-worldwide`
Android package: `com.swipebuy.worldwide`

On the build computer run:

    flutterfire configure --project=swipebuy-worldwide

Select Android to generate `lib/firebase_options.dart`.

Then generate SHA fingerprints:

    cd android
    ./gradlew signingReport

Add the appropriate SHA-1/SHA-256 fingerprints to the Android app in Firebase.

Do not share signing keys or passwords.

#!/bin/bash

# Avoid the integrations
echo -e "twitterConsumerKey=\n\ntwitterConsumerSecret=" > app/twitter.properties
mv app/google-services.sample.json app/google-services.json

# Ignore the lints
echo "
android {
    lintOptions {
        abortOnError false
    }
}" >> app/build.gradle

# Disable the filter
sed -i 's|if (Helper.isClaimBlocked(claim))|if (false)/g' $(grep -lr "if (Helper.isClaimBlocked(claim))" app/src)

# Build APKs
chmod +x gradlew
./gradlew assembleRelease --console=plain --warning-mode all

# Prepare the APKs to get signed
mkdir -p bin/
rm -f bin/*
cp app/build/outputs/apk/__32bit/release/app-__32bit-release-unsigned.apk bin/unsigned_arm.apk
cp app/build/outputs/apk/__64bit/release/app-__64bit-release-unsigned.apk bin/unsigned_arm64.apk

# Generate a key
echo "Generating a key..."
keytool -genkey -noprompt -v \
        -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=Unknown" \
        -keystore lbry-android.keystore -keyalg RSA \
        -keysize 2048 -validity 10000 -alias lbry-android \
        -storepass password \
        -keypass password
echo "The key is generated."

# sign 32-bit
echo "Signing 32-bit APK..."
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
          -keystore lbry-android.keystore -storepass password \
           bin/unsigned_arm.apk lbry-android >/dev/null
mv bin/unsigned_arm.apk bin/signed_arm.apk
zipalign -v 4 bin/signed_arm.apk bin/arm.apk >/dev/null
rm bin/signed_arm.apk
echo "32-bit APK successfully built."

# sign 64-bit
echo "Signing 64-bit APK..."
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
          -keystore lbry-android.keystore -storepass password \
          bin/unsigned_arm64.apk lbry-android >/dev/null
mv bin/unsigned_arm64.apk bin/signed_arm64.apk
zipalign -v 4 bin/signed_arm64.apk bin/arm64.apk >/dev/null
rm bin/signed_arm64.apk
echo "64-bit APK successfully built."

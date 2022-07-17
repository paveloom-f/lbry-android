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

# Set the NDK version
sed -i 's/android {/android {\n    ndkVersion "16.1.4479499"/' app/build.gradle

# Disable the filter
sed -ri 's|(Lbryio\.populateOutpointList)|// \1|g' "$(grep -lr "Lbryio.populateOutpointList" app/src)"

# Change the API link from `api.lbry.tv` to the local one
sed -ri 's|https://api\.lbry\.tv/api/v1/proxy|http://127.0.0.1:5279|g' "$(grep -lr "https://api.lbry.tv/api/v1/proxy" app/src)"

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
zipalign -v 4 bin/signed_arm.apk bin/LBRY_arm.apk >/dev/null
rm bin/signed_arm.apk
echo "32-bit APK successfully built."

# sign 64-bit
echo "Signing 64-bit APK..."
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
          -keystore lbry-android.keystore -storepass password \
          bin/unsigned_arm64.apk lbry-android >/dev/null
mv bin/unsigned_arm64.apk bin/signed_arm64.apk
zipalign -v 4 bin/signed_arm64.apk bin/LBRY_arm64.apk >/dev/null
rm bin/signed_arm64.apk
echo "64-bit APK successfully built."

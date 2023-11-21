#!/bin/bash

set -eo pipefail

# Based on https://docs.github.com/en/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development
# create variables
APPLICATION_CERT_PATH=$RUNNER_TEMP/application_cert.p12
INSTALLER_CERT_PATH=$RUNNER_TEMP/installer_cert.p12
KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db

# import certificates from secrets
echo "🏃 Retrieving Developer certificates from GH secrets …"
echo -n "$APPLICATION_CERT_BASE64" | base64 --decode --output $APPLICATION_CERT_PATH
echo -n "$INSTALLER_CERT_BASE64" | base64 --decode --output $INSTALLER_CERT_PATH
echo "✅ Done retrieving Developer certificates from GH secrets."

# create temporary keychain
echo "🏃 Creating temporary keychain …"
security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
echo "✅ Done creating temporary keychain."

# download Apple certificates
echo "🏃 Downloading Apple certificates …"
curl https://www.apple.com/appleca/AppleIncRootCertificate.cer -L --output AppleIncRootCertificate.cer
curl https://www.apple.com/certificateauthority/AppleComputerRootCertificate.cer -L --output AppleComputerRootCertificate.cer
curl http://developer.apple.com/certificationauthority/AppleWWDRCA.cer -L --output AppleWWDRCA.cer
echo "✅ Done downloading Apple certificates."

# install Apple certificates
# the following line is required for macOS 11+, see
# https://developer.apple.com/forums/thread/671582?answerId=693632022#693632022
echo "🏃 Installing Apple certificates …"
sudo security authorizationdb write com.apple.trust-settings.admin allow
sudo security add-trusted-cert -d -r trustRoot -k $KEYCHAIN_PATH ./AppleIncRootCertificate.cer
sudo security add-trusted-cert -d -r trustRoot -k $KEYCHAIN_PATH ./AppleComputerRootCertificate.cer
security add-certificates -k $KEYCHAIN_PATH ./AppleWWDRCA.cer
echo "✅ Done installing Apple certificates."

# ensure we're going to import the correct developer certificates into keychain
# echo "🏃 Running sanity check on our Developer certificates before importing …"
# openssl pkcs12 -nokeys -passin pass:"$APPLICATION_CERT_PASSWORD" -in $APPLICATION_CERT_PATH | grep friendlyName
# openssl pkcs12 -nokeys -passin pass:"$INSTALLER_CERT_PASSWORD" -in $INSTALLER_CERT_PATH | grep friendlyName
# echo "✅ Done running sanity check on our Developer certificates before importing."

# import developer certificates
echo "🏃 Importing our Developer certificates …"
security import $APPLICATION_CERT_PATH -P "$APPLICATION_CERT_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
security import $INSTALLER_CERT_PATH -P "$INSTALLER_CERT_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
echo "✅ Done importing our Developer certificates."

# ensure the imported certificates are valid
echo "🏃 Ensuring the imported cerificates are valid …"
security find-identity -v $KEYCHAIN_PATH
echo "✅ Done ensuring the imported cerificates are valid."

# Avoid a password prompt; what this actually does is not properly
# documented; see https://github.com/fastlane/fastlane/issues/13564#issue-372273249
# and https://stackoverflow.com/a/40039594
# FIXME: Really needed?
echo "🏃 Disabling keychain password prompt …"
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
echo "✅ Done disabling keychain password prompt."

# Make the keychain the default
echo "🏃 Setting default keychain …"
security default-keychain -s $KEYCHAIN_PATH
echo "✅ Done setting default keychain."

# List available signing identities (for debugging purposes)
echo "🏃 Listing available signing identities …"
security find-identity
echo "✅ Done listing available signing identities."



## Setup for Code Signing and Notarization
To enable codesigning / notarization, you first must have a valid Apple Developer account.

To sign up, go to Apple's developer site and establish an account here:

https://developer.apple.com/

You will be required to accept their developer agreements and pay an annual fee for access.

Once you have established an Apple Developer Account, log in and follow these steps:
1. ****Locally generate a Signing Request (CSR) Certificate****
    * On your local machine find and open the "Keychain Access" App. It used to be in `/Applications/Utilities` but is now in `/System/Library/CoreServices/Applications`
    * Open ****Keychain Access****
    * If prompted, select "Open Keychain Access". ****Do Not**** select "Open Passwords"
    * Under the "Keychain Access" menubar menu, Select:
    * Certificate Assistant -> Request a Certificate From a Certificate Authority.
    * Fill out the information
    * Select "Save to Disk"
    * Click on continue
    * Save the generated certificate to disk in a safe, preferably encrypted, folder — the usual name is `CertificateSigningRequest.certSigningRequest`
2. ****Establish a Developer Application ID Certificate****
    * Go to https://developer.apple.com/
    * Log in and click on the Account Icon
    * Select Account
    * Under "Certificates, IDs & Profiles" Click on ****Certificates****
    * Click on the ****+**** next to Certificates
    * Select "Developer ID Application"
    * Click Continue
    * Select `G2 Sub-CA (Xcode 11.4.1 or later)`
    * Click on "Choose File" and upload the CSR certificate generated in step 1
    * Download your new "Developer ID Application" certificate and save it to disk in a safe, preferably encrypted, folder
3. ****Load the Certificate locally into Keychain Access****
    * Find the downloaded certificate and either double-click on it or load it in Keychain Access
    * Please write down the entry you see in Keychain Access as you will require it later
    * It will look something like `Developer ID Application: Your Name (K1234)`
    * Verify the Certificate's Trust Settings in Keychain Access
    * Click on the certificate
    * Under the "File" menubar menu, Select Info
    * Expand "Trust"
    * Verify that "When Using this Certificate" is set to `System Defaults`
4. ****Optional - Update Apple PKI Certificates****
    * There's a chance you may need to update to the latest Apple PKI certificates. To do that:
    * Go to https://www.apple.com/certificateauthority/
    * Locate and Download `Developer ID - G2 (Expiring 09/17/2031 00:00:00 UTC)`
    * Double-click on the download or load via Keychain Access
5. ****Establish an App Identifier****
    * Go to https://developer.apple.com/
    * Log in and click on the Account Icon
    * Select Account
    * Under "Certificates, IDs & Profiles" Click on Identifiers
    * Click on the ****+**** next to Identifiers
    * Select "App IDs" and click on continue
    * Select "App" and click on continue
    * Provide a description like `mythfrontend`
    * Give the app a Bundle ID like `org.mythtv.mythfrontend`
    * Copy down your "App ID Prefix" for later use, something like `KWB1C2DEF (Team ID)`
    * Leave all Capabilities ****un-selected****
    * Click on Continue
6. ****Generate an App Password****
    * Go to https://account.apple.com/
    * Sign in
    * Click on "App-Specific Passwords"
    * Click on the ****+****
    * Provide the name "mythfrontend"
    * Write down the string of characters provided. Should be something like `aaaa-bbbb-cccc-dddd`
7. **Store your signing credentials in your local keychain**
    * Open terminal
    * Run the following command replacing the items you copied down earlier as appropriate:
```
xcrun notarytool store-credentials MYTHFRONTEND_APP_PWD --apple-id your_apple_id --team-id="KWB1C2DEF" --password aaaa-bbbb-cccc-dddd
```
8. ****Store some variables in your .zprofile file****
    * Open terminal
    * Edit `~/.zprofile` with your favorite editor
    * Add the following to the end of the file updating with the information copied previously:
```
export CODESIGN_ID="Developer ID Application: Your Name (K1234)"
export APPLE_ID="your_apple_id"
export APP_BNDL_ID="org.mythtv.mythfrontend"
export NOTAR_KEYCHAIN=MYTHFRONTEND_APP_PWD
```
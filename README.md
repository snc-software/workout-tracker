# workout-tracker

iOS application for tracking workout weights, built with SwiftUI.

## Requirements

- A Mac running Xcode (latest stable release recommended)
- An iPhone running iOS 26.5 or later, connected via USB or on the same Wi-Fi network as the Mac
- An Apple ID (a free personal Apple ID is enough — no paid Apple Developer Program membership required for local testing)

## Installing on your iPhone for local testing

1. **Clone the repository** (if you haven't already):
   ```
   git clone <repo-url>
   cd workout-tracker
   ```

2. **Open the project in Xcode**:
   ```
   open WorkoutTracker/WorkoutTracker.xcodeproj
   ```

3. **Add your Apple ID to Xcode** (skip if already done):
   - Xcode menu → Settings → Accounts
   - Click `+` and sign in with your Apple ID

4. **Configure signing**:
   - Select the `WorkoutTracker` project in the navigator, then the `WorkoutTracker` target
   - Go to the **Signing & Capabilities** tab
   - Ensure **Automatically manage signing** is checked
   - Set **Team** to your Apple ID (personal team)
   - Xcode will generate a provisioning profile automatically. If the bundle identifier `com.snc-software.WorkoutTracker` is already taken under your account, change it to something unique (e.g. append your name)

5. **Connect your iPhone** to the Mac with a cable, or ensure it's available wirelessly (Xcode → Window → Devices and Simulators → check "Connect via network" once paired by cable at least once)

6. **Trust the Mac on your iPhone** if prompted (a popup appears on the phone the first time it's connected)

7. **Enable Developer Mode on the iPhone** (required on iOS 16+):
   - Settings → Privacy & Security → Developer Mode → toggle on
   - The phone will prompt to restart — confirm, then unlock and confirm again after reboot

8. **Select your device as the run destination** in Xcode:
   - In the toolbar, click the scheme/device selector next to the `WorkoutTracker` scheme
   - Choose your iPhone from the list under "iOS Device"

9. **Build and run**: press `Cmd+R` (or the ▶️ button)
   - The app will build, install, and launch automatically on your iPhone

10. **Trust the developer certificate on the iPhone** (first install only):
    - On the phone: Settings → General → VPN & Device Management
    - Under "Developer App", tap your Apple ID and choose **Trust**
    - Re-open the WorkoutTracker app from the Home Screen

### Notes

- With a free (non-paid) Apple ID, the app is signed with a 7-day provisioning profile. After 7 days the app will refuse to launch and you'll need to rebuild and reinstall from Xcode (steps 8–9) to keep testing.
- To view logs while testing, use Xcode → Window → Devices and Simulators, or the Console app on the Mac while the device is connected.

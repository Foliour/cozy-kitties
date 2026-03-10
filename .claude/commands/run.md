Build and launch CozyKitties in the iOS Simulator.

Steps:
1. Find the booted simulator UDID using `xcrun simctl list devices booted -j`
2. Terminate any running instance: `xcrun simctl terminate <UDID> com.kathrynstyons.cozykitties`
3. Build: `xcodebuild build -scheme CozyKitties -destination 'platform=iOS Simulator,id=<UDID>' CODE_SIGNING_ALLOWED=NO`
4. If build fails, show the errors and stop
5. Install: `xcrun simctl install <UDID> ~/Library/Developer/Xcode/DerivedData/CozyKitties-clesgrhqsfqxnpavzclmsubatixv/Build/Products/Debug-iphonesimulator/CozyKitties.app`
6. Launch: `xcrun simctl launch <UDID> com.kathrynstyons.cozykitties`
7. Report success with the PID

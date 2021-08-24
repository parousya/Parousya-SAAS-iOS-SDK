# Parousya-SAAS-iOS-SDK
Parousya SAAS SDK is used for Parousya Automatic Check-In System (ACIS) integration. Parousya ACIS will check in the user as soon as he/she enters the place of business, among other use cases.

## Overview
Parousya SAAS SDK is a framework for Parousya ACIS integration.  This repository contains the iOS SDK and the sample project implementation on how to use the iOS SDK.

## Installation with Cocoapods
Parousya SAAS iOS SDK is distributed as a compiled bundle, and can be easily integrated into a new app or an existing codebase with standard tooling.
[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

### Podfile

To integrate ParousyaSAASSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:parousya/Parousya-SAAS-iOS-SDK.git'
platform :ios, '10.0'

target 'TargetName' do
pod 'ParousyaSAASSDK', '0.1.7' # for Xcode 11 and below, please use '0.1.4'
end
```

Then, run the following command:

```bash
$ pod install
```

### iOS Permission
The SDK will require the following iOS permission which the host app will need to configure in its `Info.plist` file.

`NSLocationWhenInUseUsageDescription` - Please set the description for this key accordingly.
`NSLocationAlwaysAndWhenInUseUsageDescription` - Please set the description for this key accordingly.
`NSLocationAlwaysUsageDescription` - Please set the description for this key accordingly.

If you need further information please check out this [article](https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_always_authorization).

These three keys are required to enable location services in iOS.

### Build Settings
Inside Target -> Capabilities tab, please turn ON `Background Modes` and enable these 3 options:
1. Uses Bluetooth LE accessories
2. Background fetch
3. Remote notifications

Inside Target -> Capabilities tab, please turn ON `Push Notifications`

## Starting
To start Parousya SAAS SDK, you will need to obtain the `APP_KEY` and `APP_SECRET` values from Parousya.
Please [contact us](https://www.parousya.com/contact) for access.

You will have 2 choice in starting Parousya SAAS client:
1. As a Host
2. As a Customer

You will need to choose between debug and production mode.  Set `isDebug: true` for debug mode and `isDebug: false` for production mode.

In the example below, we assume that the user has logged in and your app is starting the SDK as a Host.

```swift
func didLoginSuccessfully() {
    ParousyaSAASSDK.start(appKey: APP_KEY, appSecret: APP_SECRET, personGenericId: USER_ID, personType: PRSPersonType.host, isDebug: true, onSuccess: {
        // Your code here
    }) { error in
        // Your code here
    }
}
```

The SDK will automatically range for beacons (when starting as a Host or Customer) and will associate with any detected Parousya beacon.

### Notifications

There will be notifications broadcasted in the app for both Host or Customer, which the host app will need to register as an observer. This is so that the host app will receive the events that the SDK triggered.
See [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter) for more information.

These are the Notifications that Hosts and Customers should observe:

```swift
// This notification is posted when a beacon is detected
// A PRSBeaconModel object is sent along with this notification, this is the first detected beacon
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didEnterBeaconTagRegion, object: nil)

// This notification is posted when no more beacons are detected
// A PRSBeaconModel object is sent along with this notification, this is the last detected beacon
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didExitBeaconTagRegion, object: nil)

// This notification is posted when a beacon has been paired
// A PRSBeaconModel object is sent along with this notification, this is the paired beacon
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didPairBeacon, object: nil)

// This notification is posted when a beacon has been unpaired
// A PRSBeaconModel object is sent along with this notification, this is the unpaired beacon
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didUnpairBeacon, object: nil)

// This notification is posted when any sessions has been resumed
// An array of PRSSesssionStartedModel objects is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didResumeSessions, object: nil)
```

These are the Notifications that Hosts should observe:

```swift
// This notification is posted when a session has been started with a Customer
// A PRSSesssionStartedModel object is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didStartSessionWithCustomer, object: nil)

// This notification is posted when a session has been ended by a Customer
// A PRSSesssionEndedModel object is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didEndSessionByCustomer, object: nil)

// This notification is posted when a session has been terminated by the host app
// A PRSSesssionEndedModel object is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didEndSessionManually, object: nil)

// This notification is posted when all active sessions has been terminated by the host app
// An array of PRSSesssionEndedModel objects is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didEndAllSessionsManually, object: nil)
```

These are the Notifications that Customers should observe:

```swift
// This notification is posted when a session has been started with a Host
// A PRSSesssionStartedModel object is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didStartSessionWithHost, object: nil)

// This notification is posted when a session has been ended by a Host
// A PRSSesssionEndedModel object is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didEndSessionByHost, object: nil)

// This notification is posted when any active session has been terminated by the SDK
// An array of PRSSesssionEndedModel objects is sent along with this notification
NotificationCenter.default.addObserver(self, selector: #selector(YourFunction), name: Notification.Name.didEndSessionsByBeingOutOfRange, object: nil)
```

## Starting the SDK on app launch
If the user is still logged into the app after the app has been terminated, the SDK will need to be started on app launch.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ParousyaSAASSDK.start(appKey: APP_KEY, appSecret: APP_SECRET, personGenericId: USER_ID, personType: PRSPersonType.host, isDebug: true, onSuccess: {
        // Your code here
    }) { error in
        // Your code here
    }

    return true
}
```

## Stopping
The example below shows how to stop the SDK after the user has logged out of the host app.

```swift
func didLogoutSuccessfully() {
    ParousyaSAASSDK.stop(onSuccess: {
        // Your code here
    }) { error in
        // Your code here
    }
}
```

## Push Notification
Please implement the the following delegates for push notifications.  Parousya SAAS SDK will only handle push notifications that comes for the SDK ignoring the rest. Any payload received that contains the `parousya` key should be sent to the SDK for handling.

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ParousyaSAASSDK.registerPushToken(token: deviceToken, onSuccess: {
        // Your code here
    }) { error in
        // Your code here
    }
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    let payload = userInfo as NSDictionary

    if let _ = payload["parousya"] as? [String:Any] {
        ParousyaSAASSDK.processPushPayload(payload, onHandled: {
            completionHandler(.newData)
        }) {
            completionHandler(.noData)
        }
        return
    }

    // Handle your own push notifications here
    // Call completionHandler with .newData or .noData after you are done
    completionHandler(.newData)
}
```

## Example App
To run the example project, clone the repo, and run `pod install` from the Example directory first. The podfile is already there for your convenience.
```bash
$ pod install
```

After getting your `APP_KEY` and `APP_SECRET` values from Parousya, please edit those values in `Constants.swift` file.
```swift
#if DEBUG
    static let appKey = "DEV_APP_KEY"
    static let appSecret = "DEV_APP_SECRET"
#else
    static let appKey = "PROD_APP_KEY"
    static let appSecret = "PROD_APP_SECRET"
#endif
```

Now you can build the project and try out the demo on a device.

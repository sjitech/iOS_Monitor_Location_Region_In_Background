# iOS_Monitor_Location_Region_In_Background
iOS: monitor entering/leaving a specified location region, in background, even screen off, app terminated.

##Capabilities

According to iOS API reference of [CLLocationManager \- Core Location \| Apple Developer Documentation](https://developer.apple.com/reference/corelocation/cllocationmanager), an app can 
> Monitoring distinct regions of interest and generating location events when the user enters or leaves those regions

**The awsome thing is:**
> **For a terminated iOS app, this service relaunches the app to deliver events**.

This means if you restart your iOS device, it works without you start the app manually. (iOS will wakeup your app for about 10 seconds when region events occurs)

###Cavets

According to manual of [Region Monitoring](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html)
> Regions are a shared system resource, and the total number of regions available systemwide is limited. For this reason, Core Location limits to 20 the number of regions that may be simultaneously monitored by a single app

And the event may be a little delayed( As my experience, may up to 4 minutes)
> region events may not happen immediately after a region boundary is crossed. To prevent spurious notifications, iOS doesn’t deliver region notifications until certain threshold conditions are met. Specifically, the user’s location must cross the region boundary, move away from the boundary by a minimum distance, and remain at that minimum distance for at least 20 seconds before the notifications are reported.

##Detail Steps
- Requests permission to use location services whenever the app is running

[SampleFreeApp/AppDelegate.swift](https://github.com/sjitech/iOS_Monitor_Location_Region_In_Background/blob/master/SampleFreeApp/AppDelegate.swift)

The `requestAlwaysAuthorization()` will show a popup to let user choose "Allow" or "Not Allow"

```
    let locm = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        locm.delegate = self
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            myInit()
        } else {
            locm.requestAlwaysAuthorization()
        }
        return true
    }
```

- start monitoring a specific location region

Just call `startMonitoring(...a_region...)`, Please change the latitude,longitude,radius(in meater).

```
    var done_myInit = false;
    
    func myInit() {
        if (!done_myInit) {
            locm.startMonitoring(for: CLCircularRegion(
                center: CLLocationCoordinate2D(latitude:12.3456, longitude:78.9012),
                radius: CLLocationDistance(123),
                identifier: "Somewhere1"))
            done_myInit = true
        }
    }
```

- Then receive region events

I just push local notifications when entering/leaving regions.
```
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dts = dateFormatter.string(from: Date())
        
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Enter " + region.identifier + " @" + dts
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = Date.init()
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dts = dateFormatter.string(from: Date())
        
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Leave " + region.identifier + " @" + dts
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = Date.init()
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Error " + error.localizedDescription
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = Date.init()
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
```

##Interesting things

- The region you registered to monitor will be persisted in the iOS unless you call `stopMonitoring(...the_region...)`.

Even if you update your app to monitor other place (with a different identifier string), the app will still be notified of the old region events!

So be careful, do not forget to call `stopMonitoring(...the_region...)` when not neccessary.


By the way, i'v found another more complete demo app which integrate Maps app so let you choose where you want to monitor.
https://www.raywenderlich.com/136165/core-location-geofencing-tutorial

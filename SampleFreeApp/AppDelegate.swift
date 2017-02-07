//
//  AppDelegate.swift
//  SampleFreeApp
//
//  Created by q on 2017/01/12.
//  Copyright © 2017年 q. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            myInit()
        }
    }
    
    var done_myInit = false;
    
    func myInit() {
        if (!done_myInit) {
            locm.startMonitoring(for: CLCircularRegion(
                center: CLLocationCoordinate2D(latitude:PLEASE_ENTER_latitude, longitude:PLEASE_ENTER_longitude),
                radius: CLLocationDistance(PLEASE_ENTER_radius_in_meter),
                identifier: "Somewhere1"))
            done_myInit = true
        }
    }
}


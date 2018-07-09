//
//  AppDelegate.swift
//  Bubble Wrap 2.0
//
//  Created by Kyle Nakamura on 5/27/18.
//  Copyright © 2018 Kyle Nakamura. All rights reserved.
//

import UIKit    
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (isGranted, error) in
            if error != nil {
                print("KYLE: UNUserNotifcationCenter \(String(describing: error))")
            } else {
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()   // Enables notifications while app is inactive
                })
            }
        }
        
        FirebaseApp.configure()
        
        return true
    }
    
    func setupFCMConnection(shouldEstablishConnection: Bool) {
        Messaging.messaging().shouldEstablishDirectChannel = shouldEstablishConnection
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setupFCMConnection(shouldEstablishConnection: true)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        setupFCMConnection(shouldEstablishConnection: false)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("KYLE: Error fetching remote instange ID: \(error)")
            } else if let result = result {
                let newToken: String = result.token
                print("KYLE: Remote instance ID token: \(newToken)")
                self.setupFCMConnection(shouldEstablishConnection: true)
            }
        }
    }
    
    // Enable notifications while app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)   // Send an alert as soon as notification is detected (while active)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

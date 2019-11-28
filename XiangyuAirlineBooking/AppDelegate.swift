//
//  AppDelegate.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 26/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import UIKit
import Intents

extension Notification.Name {
    static let showReservation = Notification.Name("ShowReservation")
    static let startReservationCheckIn = Notification.Name("StartReservationCheckIn")
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        // Your app was launched with the INGetReservationDetailsIntent intent. You should reconfigure your UI
        // to display the reservations specified in the intent.
        if userActivity.activityType == "INGetReservationDetailsIntent" {
            let notification = Notification(name: .showReservation, object: userActivity, userInfo: nil)
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(notification)
            return true
        }
        // Your app was launched with the custom "com.example.apple-samplecode.Siri-Event-Suggestions.check-in" activity type
        // that is specified for the check-in action. You should reconfigure your UI to start the check-in flow.
        else if userActivity.activityType == "com.example.apple-samplecode.Siri-Event-Suggestions.check-in" {
            let notification = Notification(name: .startReservationCheckIn, object: userActivity, userInfo: nil)
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(notification)
            return true
        }
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


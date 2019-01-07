//
//  NotificationService.swift
//  logRegTest
//
//  Created by jed on 11/5/18.
//  Copyright © 2018 jed. All rights reserved.
//

import UserNotifications
import UIKit


enum NotificationType: String {

    case
    typing = " is typing . . .",
    newMessage = " sent a message",
    newLike = " liked your memory"

    func type() -> String { return self.rawValue }

}


extension AppDelegate: UNUserNotificationCenterDelegate {


    func requestNotifications() {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (authorized: Bool, error:Error?) in
            if !authorized {
                // do a thing
            }
        }

//        UNUserNotificationCenter.current().setNotificationCategories(Set<UNNotificationCategory>)

        UIApplication.shared.registerForRemoteNotifications()

    }


//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        <#code#>
//    }

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//    }

    static func sendNotification(to: User, from: User, notificationType: NotificationType ) {

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let content = UNMutableNotificationContent()
        //            content.title =
        content.body = from.userName + notificationType.type()
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            if error != nil {
                print("Error: \(error!.localizedDescription)!")
            }
        }

    }




}

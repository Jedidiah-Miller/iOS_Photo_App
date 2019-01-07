//
//  AppDelegate.swift
//  logRegTest
//
//  Created by jed on 7/1/18.
//  Copyright © 2018 jed. All rights reserved.


import UIKit
import Firebase
import CoreData
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var authListener: AuthStateDidChangeListenerHandle!

    var userAuthenticated: Bool = false

    var shortcutItemtoProcess: UIApplicationShortcutItem!


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        initializeApp()
        return true
    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
//            shortcutItemtoProcess = shortcutItem
//        }
//        return true
//    }



    private func initializeApp() {

        FirebaseApp.configure()

        authListener = Auth.auth().addStateDidChangeListener { auth, user in

            guard let user = user else {
                self.showLoginVC()
                return
            }

            guard let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MainViewController else { return }

            self.window?.rootViewController = mainVC
            self.window?.makeKeyAndVisible()

            NavView.disabled = true
            mainVC.navView.alpha = 0.5
            UserService.observe(user.uid) { currUser in

                if currUser != nil {

                    self.userAuthenticated = true

                    UserService.currUser = currUser

                    // UserDefaults setup here

                    mainVC.setup()

                    self.shortcutItemtoProcess != nil ? self.handleShortcutItem() : nil


                } else {

                    self.showLoginVC()

                }
            }

        }

    }




    func handleShortcutItem() {

        guard userAuthenticated, let mainVC = window?.rootViewController as? MainViewController else { return }

//        let lkj = shortcutItemtoProcess.localizedTitle.caseInsensitiveCompare("j")

        switch shortcutItemtoProcess.localizedTitle.lowercased() {

        case "selfie":  mainVC.cameraVC.runSession() // makes me nervous - works fine tho

        case "chat":

            // ISSUE - on initial launch this crashes

            mainVC.shrinkNavItems(mainVC.navView.chatButton)
            mainVC.swipeViewController.setController(to: mainVC.messageViewController, animated: false)

        default: print("default should not have been called")

        }

        shortcutItemtoProcess = nil

    }


    private func showLoginVC() {

        UserService.currUser = nil
        userAuthenticated = false
        shortcutItemtoProcess = nil

        if let mainVC = window?.rootViewController as? MainViewController {

            // probably don't need this
            mainVC.dismiss(animated: false)

        }


        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as UIViewController

        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()

    }



    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        shortcutItemtoProcess = shortcutItem

        handleShortcutItem()

    }


//    func applicationWillResignActive(_ application: UIApplication) {
//
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//
//        // grab some data for quick actions here
//
//    }


    private func resetMainVC() {

        guard let mainVC = window?.rootViewController as? MainViewController else { return }


        // check if there any additionally presented viewControllers

        for controller in mainVC.viewControllers {

            if let presentedVC = controller?.presentedViewController {

                presentedVC is ConvoVC ? print("convoVC") : print("some other viewController")

                presentedVC.view.endEditing(true)

                // if the user was doing something outside of the mainVC -> stay there
                return

            }

        }


        // reopen the camera if it's not open

        mainVC.selfViewController.closeMenuTap("chicken")

        !mainVC.cameraOpen ? mainVC.reOpenCamera(mainVC.navView.cameraButton) : nil

        if let device = mainVC.cameraVC.captureDevice {

            // switch the capture device to the back camera if needed

            device.position == .front ? mainVC.cameraVC.runSession() : nil

        }

    }


    func applicationDidEnterBackground(_ application: UIApplication) {

        // MARK ! - called when the user leaves the app

        // reset the mainVC // either end editing or reopen the camera
        resetMainVC()

    }



//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    }
//

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        print("did become active")

    }


//    func applicationWillTerminate(_ application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }


}

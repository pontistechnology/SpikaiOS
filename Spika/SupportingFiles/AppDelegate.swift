//
//  AppDelegate.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import CoreData
import AVFoundation
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationHelper = NotificationHelpers()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureFirebase()
        configureNotifications(app: application)
        customization()
//        test()
//        for family in UIFont.familyNames {
//            print("family:", family)
//            for font in UIFont.fontNames(forFamilyName: family) {
//                print("font:", font)
//            }
//        }
        return true
    }
    
    func configureFirebase() {
        FirebaseApp.configure()
        
    }
    
    func test() {
            print("_____")
            Constants.Strings.allCases.enumerated().forEach { index, element in
                print("C ", index, String.getStringFor(element))
                print(String.getStringFor(element) == element.rawValue)
            }
            print("_____")
    }
    
    
    func customization() {
        if let token = UserDefaults(suiteName: Constants.Networking.appGroupName)?.string(forKey: Constants.Database.accessToken) as? String {
            print("TOKEN: ", token)
        }
        
        guard let font =  UIFont(name: CustomFontName.MontserratSemiBold.rawValue, size: 14) else { return }
        // this is for our custom back button
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : UIColor.textPrimary
            ], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : UIColor.textPrimary
            ], for: .focused)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : UIColor.textPrimary
            ], for: .highlighted)
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor : UIColor.textPrimary
            ], for: .selected)
        
       
        let backImage = UIImage(resource: .rdBackButton).withTintColor(.textPrimary, renderingMode: .alwaysOriginal)
            .withBaselineOffset(fromBottom: 7) // without this back button title and image are not aligned
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
    }
}


// MARK: Push notifications

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
       
        guard let message = notificationHelper.decodeMessageFrom(userInfo: userInfo) else {
            completionHandler()
            return
        }
        
        let scene = UIApplication.shared.connectedScenes.first
        guard let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) else {
            completionHandler()
            return
        }
        notificationHelper.removeNotifications(withRoomId: message.roomId)
        DispatchQueue.main.async {
            sd.appCoordinator?.presentHomeScreen(startSyncAndSSE: true, startTab: .chat(withChatId: message.roomId))
            completionHandler()
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else { return }
            print("New Push fcmToken: ", token)
            let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)!
            userDefaults.set(token, forKey: Constants.Database.pushToken)
        }
    }
    
    func configureNotifications(app: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            guard success else { return }
            print("APNs registred.")
        }
        app.registerForRemoteNotifications()
    }
}


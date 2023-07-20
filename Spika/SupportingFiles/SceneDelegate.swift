//
//  SceneDelegate.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let navController = UINavigationController()
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = navController
        setDefaultAppereance()
        window?.makeKeyAndVisible()

        appCoordinator = AppCoordinator(navigationController: navController, windowScene: scene)
        appCoordinator?.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        appCoordinator?.syncAndStartSSE()
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        appCoordinator?.stopSSE()
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
    }
    
    func setDefaultAppereance() {
        let userDefaults = UserDefaults(suiteName: Constants.Networking.appGroupName)
        let rawValue = userDefaults?.integer(forKey: Constants.Database.selectedAppereanceMode) ?? 0
        let mode = UIUserInterfaceStyle(rawValue: rawValue) ?? .unspecified
        window?.overrideUserInterfaceStyle = mode
    }
}


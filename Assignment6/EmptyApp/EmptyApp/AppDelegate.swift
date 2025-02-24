//
//  AppDelegate.swift
//  EmptyApp
//
//  Created by rab on 02/15/24.
//  Copyright © 2024 rab. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var mainView: MainView!
    var destinationView: DestinationView!
    var tripView: TripView!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize UIWindow
        window = UIWindow(frame: UIScreen.main.bounds)

        // Create a root controller to manage views
        let rootController = UIViewController()
        window?.rootViewController = rootController
        
        // Initialize views
        mainView = MainView(frame: UIScreen.main.bounds)
        destinationView = DestinationView(frame: UIScreen.main.bounds)
        tripView = TripView(frame: UIScreen.main.bounds)

        // Set delegates for navigation
        mainView.delegate = self
        destinationView.delegate = self
        tripView.delegate = self

        // Add MainView initially
        rootController.view.addSubview(mainView)

        // Show window
        window?.makeKeyAndVisible()

        return true
    }
}

// Define navigation protocols for switching views
protocol NavigationDelegate: AnyObject {
    func navigateToDestinationView()
    func navigateToTripView()
    func navigateToMainView()
}

// Implement navigation methods
extension AppDelegate: NavigationDelegate {
    
    func navigateToDestinationView() {
        window?.rootViewController?.view.subviews.forEach { $0.removeFromSuperview() }
        window?.rootViewController?.view.addSubview(destinationView)
    }

    func navigateToTripView() {
        window?.rootViewController?.view.subviews.forEach { $0.removeFromSuperview() }
        window?.rootViewController?.view.addSubview(tripView)
    }

    func navigateToMainView() {
        window?.rootViewController?.view.subviews.forEach { $0.removeFromSuperview() }
        window?.rootViewController?.view.addSubview(mainView)
    }
}

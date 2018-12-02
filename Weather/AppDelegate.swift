//
//  AppDelegate.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let coordinator = MainCoordinator(window: window!)
        coordinator.start()
        
        return true
    }


}


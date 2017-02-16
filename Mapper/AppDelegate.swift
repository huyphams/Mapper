//
//  AppDelegate.swift
//  Mapper
//
//  Created by Huy Pham on 12/18/16.
//  Copyright © 2016 Huy Pham. All rights reserved.
//

// This app is super simple :D

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Setup root view controller
    let homeController = HomeController()
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    
    window.rootViewController = homeController
    window.makeKeyAndVisible()
    
    return true
  }
}


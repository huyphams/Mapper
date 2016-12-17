//
//  AppDelegate.swift
//  Mapper
//
//  Created by Huy Pham on 12/18/16.
//  Copyright © 2016 Huy Pham. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let model = Model()
        
        model.fetch { (_, _) in
            print(model.toDictionary())
        }
        
        return true
    }
}


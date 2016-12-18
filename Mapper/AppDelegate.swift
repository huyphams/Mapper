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
    let model = Model()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        model.property("Name", target: self, selector: #selector(AppDelegate.ChangeName), on: .onChange)
        model.initData(["Name": "Carrot", "ID": "A2jsdk"])
        
        return true
    }
    
    func ChangeName() {
        print(model.name)
    }
}


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
    let model = Model(dictionary: ["Name": "This name", "ID": "This is ID from super class"])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        model.property("Name", target: self, selector: #selector(AppDelegate.ChangeName), on: .onChange)
        model.name = "New name, this is change because trigger function"
        
        let methodStart = Date()
        
        // Test performance
        for _ in 0...1000000 {
            _ = Model(dictionary: ["Name": "This name", "ID": "This is ID from super class"])
        }
        
        let methodFinish = Date()
        let executionTime = methodFinish.timeIntervalSince(methodStart)
        print("Execution time: \(executionTime)")
        
        return true
    }
    
    func ChangeName() {
        print(model.name)
        print(model.id)
    }
}


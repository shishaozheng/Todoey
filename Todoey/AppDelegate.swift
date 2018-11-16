//
//  AppDelegate.swift
//  Todoey
//
//  Created by patrick_shi on 2018/11/14.
//  Copyright © 2018 patrick_shi. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            _ = try Realm()
        } catch {
            print("Error Init Realm, \(error)")
        }

        return true
    }
}


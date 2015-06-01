//
//  AppDelegate.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/26/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        LocationManager.sharedManager
        return true
    }
}


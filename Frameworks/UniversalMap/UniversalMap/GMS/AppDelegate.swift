//
//  AppDelegate.swift
//  UniversalMap
//
//  Created by Володимир on 13.09.2025.
//

import Foundation
import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDjBpjssDScoosjzCiKjj9QFqt4Q-HDRwo")
        return true
    }
}

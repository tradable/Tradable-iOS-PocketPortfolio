//
//  AppDelegate.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 05/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit
import TradableAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TradableAuthDelegate {
    
    var window:UIWindow?
    
    var shouldTransition = true

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        Tradable.sharedInstance.authDelegate = self
        
        Tradable.sharedInstance.activateAfterLaunchWithURL(url)
        
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Tradable.sharedInstance.authDelegate = self
        
        if let url = launchOptions?[UIApplicationLaunchOptionsURLKey] as? NSURL {
            Tradable.sharedInstance.activateAfterLaunchWithURL(url)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func tradableReady(forAccount: TradableAccount) {
        //Tradable is ready to be used, segue to the next controller (but only once)
        if let vc = window?.rootViewController where vc is ViewController && shouldTransition {
            shouldTransition = false
            window?.rootViewController?.performSegueWithIdentifier("showTabBarController", sender: self)
        }
        
        //add account to a list
        addAccount(forAccount)
    }
    
    func tradableAuthenticationError(error: TradableError) {
        //handle auth error
        if let acc = error.forAccount {
            removeAccount(acc)
        }
    }
}
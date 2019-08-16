//
//  AppDelegate.swift
//  iOS Example
//
//  Created by Xuan Jie Chew on 09/08/2019.
//  Copyright (c) 2019 Parousya. All rights reserved.
//

import UIKit
import ParousyaSAASSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		// Start ParousyaSAASSDK on launch if user is still logged in.
		// This is required for beacon events even when the app is terminated.
		let userDefaults = UserDefaults.standard
		if let userId = userDefaults.object(forKey: ParousyaSAASSampleClientConstants.userIdKey) as? String,
			let value = userDefaults.object(forKey: ParousyaSAASSampleClientConstants.userTypeKey) as? Int,
			let userType = PRSPersonType(rawValue: value) {
			ParousyaSAASSDK.start(appKey: ParousyaSAASSampleClientConstants.appKey, appSecret: ParousyaSAASSampleClientConstants.appSecret, personGenericId: userId, personType: userType, isDebug: true, onSuccess: {
				
			}) { error in
				
			}
		}
		
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// Pass the data object to ParousyaSAASSDK.
		ParousyaSAASSDK.registerPushToken(token: deviceToken, onSuccess: {
			
		}) { error in
			
		}
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		let payload = userInfo as NSDictionary
		
		// Parousya remote notifications will include a dictionary under the "parousya" key.
		// Pass the entire payload to ParousyaSAASSDK to handle if "parousya" key is found.
		if let _ = payload["parousya"] as? [String:Any] {
			ParousyaSAASSDK.processPushPayload(payload, onHandled: {
				completionHandler(.newData)
			}) {
				completionHandler(.noData)
			}
			return
		}
		
		// Handle your own push notifications here
		
		// Call completionHandler after you are done
		completionHandler(.noData)
	}
}


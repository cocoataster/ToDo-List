//
//  AppDelegate.swift
//  ToDo-List
//
//  Created by Eric Sans Alvarez on 11/10/2018.
//  Copyright © 2018 Eric Sans Alvarez. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		//Location of the Realm file
		print(Realm.Configuration.defaultConfiguration.fileURL!)
		
		do {
			_ = try Realm()
		} catch  {
			print("Error initializing new Realm, \(error)")
		}
		
		return true
	}
}


//
//  AppDelegate.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if Reachability.isConnectedToNetwork(){
            print("connected to network")
        }
        CoreDataStack.createSQLiteStore(storeName: "GalleryDemo") { [weak dataManager = CoreDataManager.sharedStore] result in
            switch result {
            case .sucess(let stack):
                dataManager?.dataStack = stack
                print("Data Stack Setup Successful")
            case .failure(let error):
                assertionFailure("\(error)")
            }
        }
        

        return true
    }

}


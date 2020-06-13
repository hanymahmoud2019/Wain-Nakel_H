//
//  AppDelegate.swift
//  Wain Nakel_H
//
//  Created by Hany Mahmoud on 5/24/20.
//  Copyright © 2020 Hany Mahmoud. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    //MARK:- State Restoration
    
    // instructs the system to save the state of your views and view controllers whenever the app is backgrounded
   func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
       
       return true
   }
   
    // tells the system to attempt to restore the original state when the app restarts
   func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
       
       return true
   }
    

    // MARK: - Core Data stack

     lazy var persistentContainer: NSPersistentContainer = {
         /*
          The persistent container for the application. This implementation
          creates and returns a container, having loaded the store for the
          application to it. This property is optional since there are legitimate
          error conditions that could cause the creation of the store to fail.
         */
         let container = NSPersistentContainer(name: "ResturantDBModel")
         container.loadPersistentStores(completionHandler: { (storeDescription, error) in
             if let error = error as NSError? {
                 
                 fatalError("Unresolved error \(error), \(error.userInfo)")
             }
         })
         return container
     }()

     // MARK: - Core Data Saving support

     func saveContext () {
         let context = persistentContainer.viewContext
         if context.hasChanges {
             do {
                 try context.save()
             } catch {
                 
                 let nserror = error as NSError
                 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
             }
         }
     }


}


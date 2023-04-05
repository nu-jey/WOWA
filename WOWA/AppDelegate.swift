//
//  AppDelegate.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/03.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            let realm = try Realm()
            // print(Realm.Configuration.defaultConfiguration.fileURL!)
//            try! realm.write {
//                var work1 = Work()
//                work1.target = "가슴"
//                work1.name = "벤치 프레스"
//                work1.reps = 10
//                work1.set = 4
//                var work2 = Work()
//                work2.target = "가슴"
//                work2.name = "인클라인 프레스"
//                work2.reps = 12
//                work2.set = 4
//                var workdata = WorkModel()
//                workdata.date = "2023-04-05"
//                workdata.work.append(work1)
//                workdata.work.append(work2)
//                realm.add(workdata)
//            }
            let models = realm.objects(WorkModel.self)
            print(models)

            print(models)
            
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


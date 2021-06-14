//
//  AppDelegate.swift
//  JourneeTabbed
//
//  Created by user169887 on 4/21/20.
//  Copyright © 2020 user169887. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleMaps
import GooglePlaces
import UserNotifications
import GoogleSignIn
import FirebaseAuth
import CodableFirebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{
    

    let notificationCenter = UNUserNotificationCenter.current()
    var ref: DatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID="780807526627-979dc6mesr9jck07ue1c9ui6n4urs0bd.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
    
        GMSServices.provideAPIKey("AIzaSyASeO3NXivThTkjGomh0Tr9IbG8JjvnML0")
        GMSPlacesClient.provideAPIKey("AIzaSyASeO3NXivThTkjGomh0Tr9IbG8JjvnML0")
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    struct UserModel : Codable {
        let uid: String
        let name: String
        let email: String
    }
    
    // MARK: Sign In Function
    func sign(_ signIn: GIDSignIn!,
              didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if user != nil{
            print("User email:" + user.profile.email )}
        // Check for sign in error
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // Get credential object using Google ID token and Google access token
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Authenticate with Firebase using the credential object
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
            }
                
            // Post notification after user successfully sign in
           // NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
            let user = Auth.auth().currentUser
            saveUserToDatabase(user: user!)
            print("USER AUTHENTICATED SUCCESSFULLY!!!")
            // redirects to signed in user view controller
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController")
//                vc.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController? = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
           
        }
        
        func saveUserToDatabase(user: User){
            let userObject = UserModel(uid:user.uid, name:user.displayName!, email:user.email!)
            let data = try! FirebaseEncoder().encode(userObject)
            Database.database().reference().child("users/\(userObject.uid)").setValue(data)}

            
        }

    


    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
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


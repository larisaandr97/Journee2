//
//  ViewSignInController.swift
//  JourneeTabbed
//
//  Created by user196300 on 6/13/21.
//  Copyright © 2021 user169887. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewSignInController: UIViewController {
    @IBOutlet var signInButton : GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(GIDSignIn.sharedInstance()?.presentingViewController == nil){
            GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        }
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            //signed in
        }
        else{
            GIDSignIn.sharedInstance()?.signIn()
//            print("Came back here after LOGIN")
        }
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

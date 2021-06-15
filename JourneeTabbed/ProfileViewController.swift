//
//  ProfileViewController.swift
//  JourneeTabbed
//
//  Created by user196300 on 6/14/21.
//  Copyright © 2021 user169887. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var placesVisitedLabel: UILabel!
    
    @IBAction func logOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        print("User logged out.")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
           if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "signInView") as? UIViewController {
               self.present(viewController, animated: true, completion: nil)
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user =  Auth.auth().currentUser
        nameLabel.text = user?.displayName
        emailLabel.text = user?.email
        
        let userUid = Auth.auth().currentUser?.uid
        let spots = Database.database().reference().child("users/\(userUid!)/spots")
        spots.observe(.value, with: { (snapshot: DataSnapshot!) in
            print("Count: " + String(snapshot.childrenCount))
            self.placesVisitedLabel.text = String(snapshot.childrenCount)
        
        })
    }

}

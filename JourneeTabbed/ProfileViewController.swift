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

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var placesVisitedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user =  Auth.auth().currentUser
        nameLabel.text = user?.displayName
        emailLabel.text = user?.email
        // Do any additional setup after loading the view.
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

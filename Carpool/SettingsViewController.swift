//
//  SettingsViewController.swift
//  Carpool
//
//  Created by Kartis.io on 7/27/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import FirebaseDatabase

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var feedBtn: UIButton!
    
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var notifBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!

    @IBOutlet weak var driverSwitch: UISwitch!
    
    var uid = Auth.auth().currentUser?.uid
    
    @IBAction func driverMode(_sender: Any) {
        if driverSwitch.isOn {
            self.ref.child("users/\(uid!)/driverMode").setValue(true)
        } else {
            self.ref.child("users/\(uid!)/driverMode").setValue(false)
        }
    }
    
    @IBAction func feedBtn(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.selectedIndex = 1
    }
    
    var ref: DatabaseReference!
    
    @IBAction func signOutAction(_ sender: Any) {
        try! Auth.auth().signOut()
     
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        let manager = FBSDKLoginManager()
        manager.logOut()
     
        GIDSignIn.sharedInstance().signOut()
     
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.present(vc!, animated: true, completion: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        ref = Database.database().reference()
        
        settingsBtn.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref.child("users/\(uid!)").observe(.value) { (snapshot) in
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let isDriver = snapshot.childSnapshot(forPath: "driverMode").value as! Bool
            
            self.nameLabel.text = name
            self.emailLabel.text = email
            self.driverSwitch.isOn = (isDriver) ? true : false
        }
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
}

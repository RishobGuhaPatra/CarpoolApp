//
//  ViewController.swift
//  Carpool
//
//  Created by Kartis.io on 7/25/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseDatabase

class ViewController: UIViewController, GIDSignInUIDelegate, UITabBarControllerDelegate {
        
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    var ref: DatabaseReference!

    @objc func handleGoogleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func handleFacebookSignIn() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print(error!)
            }
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else { return }
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
                if error != nil {
                    print("Error creating Facebook user:", error!)
                    return
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        googleButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        facebookButton.addTarget(self, action: #selector(handleFacebookSignIn), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.ref.child("users").child(user!.uid).updateChildValues(["name": user?.displayName as Any, "email": user?.email as Any])
                
                self.ref.child("users/\(user!.uid)").observe(.value, with: { (snapshot) in
                    if snapshot.childSnapshot(forPath: "car").value as? String == nil {
                        self.ref.child("users/\(user!.uid)").updateChildValues(["car": "N/A", "trips": "0", "language": "English", "from": "United States"])
                    }
                })
                
                self.performSegue(withIdentifier: "toFeed", sender: self)
            }
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }

}


//
//  SignUpViewController.swift
//  Carpool
//
//  Created by Kartis.io on 7/27/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EmailViewController: UIViewController {
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameUnderline: UILabel!
    
    var ref: DatabaseReference!
    
    @IBAction func segmentControl(_ sender: Any) {
        switch segmentController.selectedSegmentIndex {
        case 0:
            nameTextField.isHidden = true
            nameLabel.isHidden = true
            nameUnderline.isHidden = true
        case 1:
            nameTextField.isHidden = false
            nameLabel.isHidden = false
            nameUnderline.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        switch segmentController.selectedSegmentIndex {
        case 0:
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    
                    let alert = UIAlertController(title: "Error", message: "The email provided is not registered", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                        case .cancel:
                            print("cancel")
                        case .destructive:
                            print("destructive")
                        }}))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                self.performSegue(withIdentifier: "toFeed", sender: self)
            })
        case 1:
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    print("Error creating user with Email:", error!)
                    return
                }
            
                let changeReq = Auth.auth().currentUser?.createProfileChangeRequest()
                changeReq?.displayName = self.nameTextField.text!
                changeReq?.commitChanges()
            
                let uid = Auth.auth().currentUser?.uid
                self.ref.child("users").child(uid!).setValue(["name": self.nameTextField.text!, "email": self.emailTextField.text!])
                
                self.ref.child("users/\(uid!)").observe(.value, with: { (snapshot) in
                    if snapshot.childSnapshot(forPath: "car").value as? String == nil {
                        self.ref.child("users/\(uid!)").updateChildValues(["car": "N/A", "trips": "0", "language": "English", "from": "United States"])
                    }
                })
                
                self.performSegue(withIdentifier: "toFeed", sender: self)
            })
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        nameTextField.isHidden = true
        nameLabel.isHidden = true
        nameUnderline.isHidden = true
        
        self.segmentController.layer.cornerRadius = 5.0
        self.segmentController.layer.borderColor = UIColor.white.cgColor
        self.segmentController.layer.borderWidth = 1.0
        self.segmentController.layer.masksToBounds = true
        
    }
}

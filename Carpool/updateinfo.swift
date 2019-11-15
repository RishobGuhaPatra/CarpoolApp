//
//  updateinfo.swift
//  Hitchhiker
//
//  Created by Kartis.io on 8/27/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class updateinfo: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var car: UITextField!
    @IBOutlet weak var trips: UITextField!
    @IBOutlet weak var lang: UITextField!
    @IBOutlet weak var from: UITextField!
    @IBOutlet weak var update: UIButton!
    
    @IBAction func updateinfo(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        
        if car.text != "" {
            self.ref.child("users/\(uid!)").updateChildValues(["car": car.text!])
        }
        
        if trips.text != "" {
            self.ref.child("users/\(uid!)").updateChildValues(["trips": trips.text!])
        }
        
        if lang.text != "" {
            self.ref.child("users/\(uid!)").updateChildValues(["language": lang.text!])
        }
        
        if from.text != "" {
            self.ref.child("users/\(uid!)").updateChildValues(["from": from.text!])
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        ref = Database.database().reference()
        
    }
}

//
//  profile.swift
//  Hitchhiker
//
//  Created by Kartis.io on 8/27/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class profile: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var car: UILabel!
    @IBOutlet weak var trips: UILabel!
    @IBOutlet weak var lang: UILabel!
    @IBOutlet weak var from: UILabel!
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("users/\(uid!)").observe(.value) { (snapshot) in
            self.car.text = snapshot.childSnapshot(forPath: "car").value as! String!
            self.trips.text = snapshot.childSnapshot(forPath: "trips").value as! String!
            self.lang.text = snapshot.childSnapshot(forPath: "language").value as! String!
            self.from.text = snapshot.childSnapshot(forPath: "from").value as! String!
        }
    }
}


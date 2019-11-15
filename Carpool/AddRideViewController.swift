//
//  AddRideViewController.swift
//  Carpool
//
//  Created by Kartis.io on 7/25/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddRideViewController: UIViewController, UITextFieldDelegate {

    var ref: DatabaseReference!

    @IBOutlet weak var source: UITextField!
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBAction func postAction(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        let name = Auth.auth().currentUser?.displayName
        
        if source.text! == "" || destination.text! == "" {
            let alert = UIAlertController(title: "Error", message: "You must enter both FROM and TO locations", preferredStyle: UIAlertControllerStyle.alert)
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time = dateFormatter.string(from: (timePicker?.date)!)
        
        self.ref.child("rides").child(uid!).setValue(["rider": name!, "source": source.text!, "destination": destination.text!, "time": time, "ID": uid!])
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        timePicker.setValue(UIColor.init(red: 191, green: 195, blue: 186, alpha: 1), forKeyPath: "textColor")
        
        self.source.delegate = self
        self.destination.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

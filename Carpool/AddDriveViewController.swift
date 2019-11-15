//
//  AddDriveViewController.swift
//  Carpool
//
//  Created by Kartis.io on 7/25/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddDriveViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var source: UITextField!
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var costUp: RoundUIButton!
    @IBOutlet weak var costDown: RoundUIButton!
    @IBOutlet weak var seats: UILabel!
    @IBOutlet weak var seatsUp: RoundUIButton!
    @IBOutlet weak var seatsDown: RoundUIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var costCount = 0
    var seatCount = 1
    
    @IBAction func costUpAction(_ sender: Any) {
        costCount += 1
        cost.text = "$\(costCount)"
    }
    
    @IBAction func costDownAction(_ sender: Any) {
        if costCount == 0 {
            return
        }
        
        costCount -= 1
        cost.text = "$\(costCount)"
    }
    
    @IBAction func seatsUpAction(_ sender: Any) {
        seatCount += 1
        seats.text = "\(seatCount)"
    }
    
    @IBAction func seatsDownAction(_ sender: Any) {
        if seatCount <= 1 {
            return
        }
        
        seatCount -= 1
        seats.text = "\(seatCount)"
    }
    
    @IBAction func postAction(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        let driver = Auth.auth().currentUser?.displayName
        
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
        
        let seatText = (seats.text! == "1") ? " seat" : " seats"
        //let stopText = (stops.text! == "1") ? " stop" : " stops"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time = dateFormatter.string(from: (timePicker?.date)!)
        
        self.ref.child("drives").child(uid!).setValue(["driver": driver!, "source": source.text!, "destination": destination.text!, "cost": "\(costCount)", "seats": seats.text! + seatText, "time": time, "stops": "0", "ID": uid!])
        
        self.tabBarController?.selectedIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        cost.text = "$\(costCount)"
        seats.text = "\(seatCount)"
        
        timePicker.setValue(UIColor.init(red: 191, green: 195, blue: 186, alpha: 1), forKeyPath: "textColor")
        
        self.source.delegate = self
        self.destination.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let uid = Auth.auth().currentUser?.uid

        ref.child("users/\(uid!)/driverMode").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? Bool
            
            if !value! {
                let alert = UIAlertController(title: "Error", message: "You are not a registered driver", preferredStyle: UIAlertControllerStyle.alert)
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
                
                self.tabBarController?.selectedIndex = 1
                return
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


//
//  FeedViewController.swift
//  Carpool
//
//  Created by Kartis.io on 7/25/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FirebaseDatabase
import GoogleSignIn
import CoreLocation

class FeedCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var seats: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var stops: UILabel!
    var isRide: Bool!
}


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var ref: DatabaseReference!, drives = [Drive]()
    var filteredDrives = [Drive]()
    let refreshControl = UIRefreshControl()
    var isSearching = false
    
    func geocodeAddress(address : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredDrives.count
        }
        
        return self.drives.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FeedCell {

            var drive: Drive!
            
            if isSearching {
                drive = filteredDrives[indexPath.row]
            } else {
                drive = drives[indexPath.row]
            }
            
            cell.name.text = drive.name
            cell.source.text = drive.source
            cell.destination.text = drive.destination
            cell.cost.text = drive.cost
            cell.seats.text = drive.seats
            cell.time.text = drive.time
            cell.stops.text = drive.stops
            cell.isRide = drive.isRide
            
            cell.cost.isHidden = (cell.cost.text == "" || cell.cost.text == nil) ? true : false
            cell.seats.isHidden = (cell.seats.text == "" || cell.seats.text == nil) ? true : false
            cell.stops.isHidden = (cell.stops.text == "0" || cell.stops.text == "" || cell.stops.text == nil) ? true : false
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        
        if !drives[indexPath.row].isRide {
            vc?.cost = drives[indexPath.row].cost
            vc?.seats = drives[indexPath.row].seats
            vc?.stops = drives[indexPath.row].stops
            vc?.isRide = false
        } else {
            vc?.isRide = true
        }
        
        vc?.driver = drives[indexPath.row].name
        vc?.source = drives[indexPath.row].source
        vc?.destination = drives[indexPath.row].destination
        vc?.time = drives[indexPath.row].time
        vc?.ID = drives[indexPath.row].ID
        
        geocodeAddress(address: drives[indexPath.row].source, completionHandler: { (location, error) in
            if error != nil {
                print(error!)
                return
            }
    
            vc?.sourceCoords = location
        })
        
        geocodeAddress(address: drives[indexPath.row].destination, completionHandler: { (location, error) in
            if error != nil {
                print(error!)
                return
            }
   
            vc?.destCoords = location
        })
                
        self.navigationController?.pushViewController(vc!, animated: true)
     }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" || searchBar.text == nil {
            isSearching = false
            view.endEditing(true)
            self.tableView.reloadData()
        } else {
            isSearching = true
            filteredDrives = drives.filter({$0.destination.lowercased().contains(searchText.lowercased())})
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        ref = Database.database().reference()
                        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshRides(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drives.removeAll()
        loadDrives()
        loadRides()
    }
    
    @objc func refreshRides(_ sender: Any) {
        drives.removeAll()
        loadDrives()
        loadRides()
        
        refreshControl.endRefreshing()
    }
    
    func loadDrives() {
        self.ref.child("drives").observe(.childAdded) { (snapshot) in
            let driver = snapshot.childSnapshot(forPath: "driver").value as! String!
            let source = snapshot.childSnapshot(forPath: "source").value as! String!
            let destination = snapshot.childSnapshot(forPath: "destination").value as! String!
            let cost = snapshot.childSnapshot(forPath: "cost").value as! String!
            let seats = snapshot.childSnapshot(forPath: "seats").value as! String!
            let time = snapshot.childSnapshot(forPath: "time").value as! String!
            let stops = snapshot.childSnapshot(forPath: "stops").value as! String!
            let ID = snapshot.childSnapshot(forPath: "ID").value as! String!
            
            self.drives.append(Drive(name: driver, source: source, destination: destination, cost: cost, seats: seats, time: time, stops: stops, ID: ID, isRide: false))
            
            self.tableView.reloadData()
        }
    }
    
    func loadRides() {
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("users/\(uid!)/driverMode").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Bool else {
                self.ref.child("users/\(uid!)/driverMode").setValue(false)
                return
            }
            
            if !value {
                self.ref.child("rides").observe(.childAdded) { (snapshot) in
                    let rider = snapshot.childSnapshot(forPath: "rider").value as! String!
                    let source = snapshot.childSnapshot(forPath: "source").value as! String!
                    let destination = snapshot.childSnapshot(forPath: "destination").value as! String!
                    let time = snapshot.childSnapshot(forPath: "time").value as! String!
                    let ID = snapshot.childSnapshot(forPath: "ID").value as! String!
                    
                    self.drives.append(Drive(name: rider, source: source, destination: destination, cost: nil, seats: nil, time: time, stops: nil, ID: ID, isRide: true))
                
                    self.tableView.reloadData()
                }
            }
        }
    }

}

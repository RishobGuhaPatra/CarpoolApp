//
//  MapViewController.swift
//  Carpool
//
//  Created by Kartis.io on 8/4/18.
//  Copyright © 2018 Kartis.io. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import PassKit
import Stripe

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var costLabel: RoundUILabel!
    @IBOutlet weak var timeLabel: RoundUILabel!
    @IBOutlet weak var seatsLabel: RoundUILabel!
    @IBOutlet weak var stopsLabel: RoundUILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var payTypeBtn: UIButton!
    
    @IBAction func payType(_ sender: Any) {
        //stripe
        self.paymentContext.presentPaymentMethodsViewController()
    }
    
    @IBAction func pay(_ sender: Any) {
        //stripe
        self.paymentContext.requestPayment()
    }
    
    var paymentContext: STPPaymentContext!
    let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
    
    var ref: DatabaseReference!
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        let user = Auth.auth().currentUser?.displayName
        var riders = [String]()
        riders.append(user!)
        
        let path = (self.isRide) ? "rides/\(ID)/riders" : "drives/\(ID)/riders"
        ref.child("\(path)").observeSingleEvent(of: .value) { (snapshot) in
            let currentRiders = snapshot.value as? NSArray
            
            if currentRiders == nil {
                self.ref.child("\(path)").setValue(riders)
            } else {
                for r in currentRiders! {
                    riders.append(r as! String)
                }
                
                self.ref.child("\(path)").setValue(riders)
            }
        }
    
        joinButton.isHidden = true
        payButton.isHidden = false
        payTypeBtn.isHidden = false
        
        if costLabel.isHidden { payButton.isHidden = true }

    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        let noLocation = CLLocationCoordinate2D(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
        let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 600, 600)
        mapView.setRegion(viewRegion, animated: true)
    }

    @IBAction func routeButtonPressed(_ sender: Any) {
        if sourceCoords == nil {
            return
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(sourceCoords.latitude, sourceCoords.longitude))
        let destPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(destCoords.latitude, destCoords.longitude))
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40.0, left: 20.0, bottom: 20.0, right: 20.0), animated: true)
            
            let sourcePin = MKPointAnnotation()
            sourcePin.coordinate = self.sourceCoords
            sourcePin.title = "Start"
            let destPin = MKPointAnnotation()
            destPin.coordinate = self.destCoords
            destPin.title = "End"
            self.mapView.addAnnotations([sourcePin, destPin])
            
        }
    }
    
    
    let manager = CLLocationManager()
    var driver = ""
    var source = ""
    var destination = ""
    var cost = ""
    var seats = ""
    var time = ""
    var stops = ""
    var ID = ""
    var isRide: Bool!
    var sourceCoords: CLLocationCoordinate2D!
    var destCoords: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        manager.requestWhenInUseAuthorization()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        driverLabel.text = driver
        sourceLabel.text = source
        destinationLabel.text = destination
        costLabel.text = cost
        seatsLabel.text = seats
        timeLabel.text = time
        stopsLabel.text = stops
        
        costLabel.isHidden = (costLabel.text == "" || costLabel.text == nil || costLabel.text == "$0") ? true : false
        seatsLabel.isHidden = (seatsLabel.text == "" || seatsLabel.text == nil) ? true : false
        stopsLabel.isHidden = (stopsLabel.text == "0" || stopsLabel.text == "" || stopsLabel.text == nil) ? true : false
        
        let path = (isRide) ? "rides/\(ID)/riders" : "drives/\(ID)/riders"
        ref.child("\(path)").observeSingleEvent(of: .value) { (snapshot) in
            let user = Auth.auth().currentUser?.displayName
            let value = snapshot.value as? NSArray
            
            if value == nil {
                return
            }

            self.joinButton.isHidden = (value?.contains(user!))! ? true : false
        }
        
        //stripe
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        
        if !self.costLabel.isHidden {
            self.paymentContext.paymentAmount = Int(self.cost)! * 100
        } else {
            self.payButton.isHidden = true
            self.payTypeBtn.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.joinButton.isHidden {
            self.payButton.isHidden = false
            self.payTypeBtn.isHidden = false
        } else {
            self.payButton.isHidden = true
            self.payTypeBtn.isHidden = true
        }
        
        if self.costLabel.isHidden {
            self.payButton.isHidden = true
            self.payTypeBtn.isHidden = true
        } else {
            self.payButton.isHidden = false
            self.payTypeBtn.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let region = MKCoordinateRegionMakeWithDistance((location?.coordinate)!, 600, 600)
        self.mapView.setRegion(region, animated: true)
    }
    
}

//stripe
extension MapViewController: STPPaymentContextDelegate {
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print(error.localizedDescription)
        self.navigationController?.popViewController(animated: true)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.payButton.setTitle(paymentContext.selectedPaymentMethod?.label, for: .normal)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        MyAPIClient().completeCharge(paymentResult, amount: Int(self.cost)!) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("status:", status.rawValue)
        print("error:", error?.localizedDescription ?? "none")
    }
    
}

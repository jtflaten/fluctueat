//
//  VendorMapViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/19/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class VendorMapViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var mapRegion = MKCoordinateRegion()
    let mapSize = MKMapSize(width: 0.5, height: 0.5)
    let timeThisVCOpened = Date()
    var ref: DatabaseReference!


    @IBOutlet weak var vendorMapView: MKMapView!
 //   @IBOutlet weak var openUntil: UIDatePicker!
  //  @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
       // configureDatePicker(datePicker: openUntil)
        getLocation()
        addLocationToVendor()
        configureMapView()
        configureBackground()

    }
    

//    @IBAction func saveTapped(_ sender: Any) {
//        isInternetAvailable() { answer in
//            guard answer == true else {
//                self.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
//                return
//            }
//        }
//
//        FirebaseClient.sharedInstance.sendVendorDataForDataBase()
//        //sendVendorDataForDataBase()
//    }
//    
//    @IBAction func closeTapped(_ sender: Any) {
//        FirebaseClient.sharedInstance.removeFromOpenVendorDB()
//    }
    
    func addLocationToVendor() {
        userVendor.lat = globalUserPlace.latitude
        userVendor.long = globalUserPlace.longitude
        
    }
//    func configureDatePicker(datePicker: UIDatePicker) {
//        datePicker.isHidden = true
        //DATE picker for setting a closing time. to be added
//        let maxTime = timeThisVCOpened.addingTimeInterval(12 * 60 * 60)
//        
//        datePicker.minimumDate = timeThisVCOpened
//        datePicker.maximumDate = maxTime
        
//    }
    
//    func getCloseTime() -> String {
//
//        let closingTime = openUntil.date.description(with: .current)
//
//
//
//        return closingTime
//
//    }
//
//    func totalOpenTime() -> String {
//        let timeUntilClose: TimeInterval = openUntil.date.timeIntervalSinceNow
//        let openTimeString = timeUntilClose.description
//
//        return openTimeString
//    }
    
 
    func configureBackground() {
        
        //        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red:0.90, green:0.76, blue:0.13, alpha:1.0).cgColor
        let colorBottom = UIColor(red:0.82, green:0.01, blue:0.11, alpha: 1.0).cgColor
        //
        //        backgroundGradient.colors = [colorTop, colorBottom]
        //        backgroundGradient.locations = [0.0, 1.0]
        //        backgroundGradient.frame = view.frame
        //        view.layer.insertSublayer(backgroundGradient, at: 0)
        view.layer.backgroundColor = colorTop
    }
    
    func getLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            vendorMapView.setCenter(userLocation, animated: true)
            userVendor.lat = userLocation.latitude
            userVendor.long = userLocation.longitude
            mapRegion = MKCoordinateRegion(center: userLocation, span: MapConstants.mapRangeSpan)
            vendorMapView.setRegion(mapRegion, animated: true)
            
            
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            self.vendorMapView.addAnnotation(userAnnotation)
            
        }
    }
    
    func configureMapView() {
        vendorMapView.isScrollEnabled = false
        vendorMapView.isZoomEnabled = true
        vendorMapView.isPitchEnabled = false
        vendorMapView.region = mapRegion
    }
    

    func configureDatabase() {
        ref = Database.database().reference()
    }
    
}

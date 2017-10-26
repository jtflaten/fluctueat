//
//  HomeMapViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/14/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // create the total map area for the mapView
    
    let locationManager = CLLocationManager()
    var vendorsAnnotations = [Vendor]()
    var mapAnnotations = [MKAnnotation]()
    
    
    var mapRegion = MKCoordinateRegion()
    let mapSize = MKMapSize(width: 10, height: 10)
    var isConnected = true
    
    
    
    
    
   
    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getLocation()
        FirebaseClient.sharedInstance.anonSignIn(vc: self)
        configureMapView()
        isInternetAvailable() { answer in
            guard answer == true else {
                self.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FirebaseClient.sharedInstance.configureDatabase(vc: self)
        configureMapView()
        
    }

    func getLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } 
        
        if let userLocation = locationManager.location?.coordinate {
            mapView.setCenter(userLocation, animated: true)
            userVendor.lat = userLocation.latitude
            userVendor.long = userLocation.longitude
            mapRegion = MKCoordinateRegion(center: userLocation, span: MapConstants.mapRangeSpan)
            mapView.setRegion(mapRegion, animated: true)
            
            
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            userAnnotation.title = "This is You"
            self.mapView.addAnnotation(userAnnotation)
            
            
           globalUserPlace = userPlace(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
        }
    }
    
  
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            if pinView!.annotation?.title! == "This is You" {
                pinView?.pinTintColor = .blue
                pinView?.rightCalloutAccessoryView = nil
            }
            pinView!.annotation = annotation
        } else {
            pinView!.annotation = annotation
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
            
        return pinView
        
    
    }
    
    func findRightVendor(name: String, desc: String) -> Vendor? {

        for openVendor in FirebaseClient.sharedInstance.openVendors {
           
            if name == openVendor.name! && desc == openVendor.description! {
                return openVendor
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let truckInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "FoodTruckInfoViewController") as! FoodTruckInfoViewController
        
        let annotationName = view.annotation?.title
        let annotationDesc = view.annotation?.subtitle
        let selectedVendor = findRightVendor(name: annotationName!!, desc: annotationDesc!!)
        truckInfoViewController.vendor = selectedVendor
        self.navigationController!.pushViewController(truckInfoViewController, animated: true)
    }
    
    func updateLocation() {
        
        
    }
    
    func makeVendorAnnotations(){
        var vendorAnnotation = [MKPointAnnotation]()
        for vendor in FirebaseClient.sharedInstance.openVendors {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(vendor.lat), longitude: CLLocationDegrees(vendor.long))
            annotation.title = vendor.name!
            annotation.subtitle = vendor.description!
            annotation.coordinate = coordinate
           
            
            vendorAnnotation.append(annotation)
        }
        
        
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapAnnotations)
            self.mapView.addAnnotations(vendorAnnotation)
            self.mapAnnotations = vendorAnnotation
        }
        
    }
    
    func configureMapView() {
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = false
        mapView.region = mapRegion
    }

    
    @IBAction func vendorButton(_ sender: Any) {
        
    }
    
//    This gesture will eventually be used to replace the "vendor" button on the mapVC
    
//    func swipeToVendor(gestureRecognizer: UISwipeGestureRecognizer){
//        let authController = self.storyboard?.instantiateViewController(withIdentifier: "AuthTabController") as! VendorTabController
//        print("swiped2")
//        
//        self.navigationController!.present(authController, animated: true)
//    }
}



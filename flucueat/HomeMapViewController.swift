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
    //TODO: make sure to abstract the hard coded numbers to constants
    let locationManager = CLLocationManager()
    var vendors = [Vendor]()
    
    
    //let userLocation = CLLocation().coordinate
    var mapRegion = MKCoordinateRegion()
    let mapSize = MKMapSize(width: 1.2, height: 1.2)
    
    
    
    
   
    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        FirebaseClient.sharedInstance.anonSignIn()
        FirebaseClient.sharedInstance.configureDatabase()
       
        print(vendors)
  //      FirebaseClient.sharedInstance.configureAuth(vc: self)
        configureMapView()
        

        
        let twoFingerSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(HomeMapViewController.swipeToVendor))
        twoFingerSwipeGestureRecognizer.numberOfTouchesRequired = 2
        twoFingerSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up
        
        self.mapView.addGestureRecognizer(twoFingerSwipeGestureRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
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
            self.mapView.addAnnotation(userAnnotation)
            
           globalUserPlace = userPlace(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
        }
    }
    
    func configureMapView() {
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = false
        mapView.region = mapRegion
    }
    
   func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        if /* !manuallyChangingMap && */ ((mapView.region.span.latitudeDelta > mapRegion.span.latitudeDelta * 4) ||
//            (mapView.region.span.longitudeDelta > mapRegion.span.longitudeDelta * 4) ||
//            fabs(mapView.region.center.latitude - mapRegion.center.latitude) > mapRegion.span.latitudeDelta ||
//            fabs(mapView.region.center.longitude - mapRegion.center.longitude) > mapRegion.span.longitudeDelta) {
//         mapView.setRegion(mapRegion, animated: true)
//        }
        print("the Region has changed!")
    }
    
    
    
    func swipeToVendor(gestureRecognizer: UISwipeGestureRecognizer){
        let authController = self.storyboard?.instantiateViewController(withIdentifier: "AuthTabController") as! VendorTabController
        print("swiped2")
        self.present(authController, animated: true)
    }
}

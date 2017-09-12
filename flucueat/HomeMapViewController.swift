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
    var vendorsAnnotations = [Vendor]()
    
    
    //let userLocation = CLLocation().coordinate
    var mapRegion = MKCoordinateRegion()
    let mapSize = MKMapSize(width: 1.2, height: 1.2)
    
    
    
    
   
    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getLocation()
        FirebaseClient.sharedInstance.anonSignIn()
      //  FirebaseClient.sharedInstance.configureDatabase(vc: self)
     //   makeVendorAnnotations()

        
  //      FirebaseClient.sharedInstance.configureAuth(vc: self)
        configureMapView()
        
        

        
        let twoFingerSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(HomeMapViewController.swipeToVendor))
        twoFingerSwipeGestureRecognizer.numberOfTouchesRequired = 2
        twoFingerSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up
        
        self.mapView.addGestureRecognizer(twoFingerSwipeGestureRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseClient.sharedInstance.configureDatabase(vc: self)
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
            self.mapView.addAnnotations(vendorAnnotation)
        }
        
    }
    func configureMapView() {
        mapView.isScrollEnabled = true
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
        
        self.navigationController!.present(authController, animated: true)
    }
}



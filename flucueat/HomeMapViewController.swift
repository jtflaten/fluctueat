//
//  HomeMapViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/14/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import MapKit


class HomeMapViewController: UIViewController, MKMapViewDelegate  {
    
    // create the total map area for the mapView
    
    let locationManager = CLLocationManager()
    var vendorsAnnotations = [Vendor]()
    var mapAnnotations = [MKAnnotation]()
    
    
   // var mapRegion = MKCoordinateRegion()
    let mapSize = MKMapSize(width: 10, height: 10)
    var isConnected = true
    var isUserInteractionChange = false
    
    
    let regionRadious: CLLocationDistance = 5000
    let houstonRegion = MKCoordinateRegionMake(MapConstants.houstonCenter, MapConstants.mapRangeSpan)
   
    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        isInternetAvailable() { answer in
            guard answer == true else {
                self.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                return
            }
        }
       
        setupLocationManager()
        FirebaseClient.sharedInstance.anonSignIn(vc: self)
        FirebaseClient.sharedInstance.configureVendor()
        mapView.delegate = self
       // mapView.setRegion(houstonRegion, animated: true)
        setMap()
        
        if #available(iOS 11.0, *) {
            mapView.register(MarkerView.self, forAnnotationViewWithReuseIdentifier: "truckMarker")
        } else {
        
        }
        
       
        
    //    checkForCenter()
      
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hideNavBar()
        FirebaseClient.sharedInstance.configureDatabase(vc: self)
        configureMapView()
        
    }
    
    func blurEstablishedRegion() {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blur)
    
       //blurView.frame = establishedRegion
    }
    
    func checkForCenter() {
        if !isInRegion(region: houstonRegion, coordinate: mapView.centerCoordinate) {
            mapView.centerCoordinate = MapConstants.houstonCenter
            mapView.setRegion(houstonRegion, animated: true)
        }
    }
    
    func isInRegion (region : MKCoordinateRegion, coordinate : CLLocationCoordinate2D) -> Bool {
        
        let center   = region.center;
        let northWestCorner = CLLocationCoordinate2D(latitude: center.latitude  - (region.span.latitudeDelta  / 2.0), longitude: center.longitude - (region.span.longitudeDelta / 2.0))
        let southEastCorner = CLLocationCoordinate2D(latitude: center.latitude  + (region.span.latitudeDelta  / 2.0), longitude: center.longitude + (region.span.longitudeDelta / 2.0))
        
        return (
            coordinate.latitude  >= northWestCorner.latitude &&
                coordinate.latitude  <= southEastCorner.latitude &&
                
                coordinate.longitude >= northWestCorner.longitude &&
                coordinate.longitude <= southEastCorner.longitude
        )
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

    }
    
    func setMap() {
        configureMapView()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            mapView.setCenter(MapConstants.houstonCenter, animated: true)
            mapView.setRegion(houstonRegion, animated: true)
        }
        
        if let userLocation = locationManager.location?.coordinate  {
            mapView.setCenter(userLocation, animated: true)
            userVendor.lat = userLocation.latitude
            userVendor.long = userLocation.longitude
            let mapRegion = MKCoordinateRegion(center: userLocation, span: MapConstants.mapRangeSpan)
               if isInRegion(region: establishedRegion, coordinate: userLocation){
                    mapView.setRegion(mapRegion, animated: true)
            } else {
                alertView(title: alertStrings.locationOutsideRegion, message: alertStrings.locationOutsideRegionMessage, dismissAction: alertStrings.showMe)
                mapView.setCenter(MapConstants.houstonCenter, animated: true)
                mapView.setRegion(houstonRegion, animated: true)

            }
            
            
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            userAnnotation.title = "This is You"
            self.mapView.addAnnotation(userAnnotation)
            
            
           globalUserPlace = userPlace(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
        } else {
        
            
        mapView.setCenter(MapConstants.houstonCenter, animated: true)
        print(mapView.center)
        mapView.setRegion(establishedRegion, animated: true)
        alertView(title: alertStrings.noCoreLocation, message: alertStrings.locationOutsideRegionMessage, dismissAction: alertStrings.showMe)
        
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "truckMarker"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if #available(iOS 11.0, *) {
            pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MarkerView
        } else {
            pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? ImageMarkerView
        }
        
        if pinView == nil {
            if #available(iOS 11.0, *) {
                pinView = MarkerView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                pinView = ImageMarkerView(annotation: annotation, reuseIdentifier: reuseId)
            }
            pinView!.canShowCallout = true
           // pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            if pinView!.annotation?.title! == "This is You" {
                pinView!.image = #imageLiteral(resourceName: "mapPerson")
                //pinView!.rightCalloutAccessoryView = nil
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
        
        if view.annotation?.title! == "This is You" {
            pushToVendor()
            return
        }
        
        let selectedVendor = findRightVendor(name: annotationName!!, desc: annotationDesc!!)
        truckInfoViewController.vendor = selectedVendor
        self.navigationController!.pushViewController(truckInfoViewController, animated: true)
    }
    
    private func userInteractionChange() -> Bool {
        let view = self.mapView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended  {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    isUserInteractionChange = userInteractionChange()
        if isUserInteractionChange{
                if !isInRegion(region: establishedRegion, coordinate: mapView.region.center) {
                alertView(title: alertStrings.outsideRegion, message: alertStrings.outsideRegionMessage, dismissAction: alertStrings.ok)
                mapView.setRegion(houstonRegion, animated: true)
                }
            }
    }
    
    
    func updateLocation() {
        
        
    }
    
    func makeVendorAnnotations(){
        var vendorAnnotation = [MKAnnotation]()
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
       
    }

    func hideNavBar() {
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
   @IBAction func vendorButton(_ sender: Any) {

    pushToVendor()
//
   }
    
//    This gesture will eventually be used to replace the "vendor" button on the mapVC
    func pushToVendor() {
        FirebaseClient.sharedInstance.configureAuth(vc: self)
        if !userVendor.isAuthorizedVendor {
            FirebaseClient.sharedInstance.loginSession(presentingVC: self)
        }
        let vendorUserTabController = self.storyboard?.instantiateViewController(withIdentifier: "VendorTabController")
        self.navigationController!.pushViewController(vendorUserTabController!, animated: true)
    }
}

extension HomeMapViewController: CLLocationManagerDelegate {
    
}

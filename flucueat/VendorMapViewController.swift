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

class VendorMapViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var mapRegion = MKCoordinateRegion()
    let mapSize = MKMapSize(width: 0.5, height: 0.5)

    @IBOutlet weak var vendorMapView: MKMapView!
    @IBOutlet weak var openUntil: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
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
    
}

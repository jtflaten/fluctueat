//
//  VendorTabController.swift
//  
//
//  Created by Jake Flaten on 7/19/17.
//
//

import UIKit
import CoreLocation

class VendorTabController: UITabBarController, CLLocationManagerDelegate {
  
    let locationManager = CLLocationManager()
    
    public func getLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
}

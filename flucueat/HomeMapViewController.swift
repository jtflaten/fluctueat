//
//  HomeMapViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/14/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import MapKit

class HomeMapViewController: UIViewController, MKMapViewDelegate {
    
    // create the total map area for the mapView
    //TODO: make sure to abstract the hard coded numbers to constants
   
    let mapRegion = MKCoordinateRegion(center: MapConstants.houstonCenter, span: MapConstants.mapRangeSpan)
    let mapSize = MKMapSize(width: 1.2, height: 1.2)
    
    
   
    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setRegion(mapRegion, animated: false)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = false
        mapView.region = mapRegion
        
        let twoFingerSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(HomeMapViewController.swipeToAuthPage))
        twoFingerSwipeGestureRecognizer.numberOfTouchesRequired = 2
        twoFingerSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up
        
        self.mapView.addGestureRecognizer(twoFingerSwipeGestureRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
    }


//    lazy var restrictedRegion: MKCoordinateRegion = {
//        // sets maps to univeristy
//        let location = CLLocationCoordinate2DMake(42.9633, -85.890042)
//        // Span and region
//        let span = MKCoordinateSpanMake (0.005, 0.005)
//        return MKCoordinateRegion(center: location, span: span)
//    }()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mapView.setRegion(restrictedRegion, animated: true)
//    }
    
  //  var manuallyChangingMap = false //Stop from updating while animating
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        if /* !manuallyChangingMap && */ ((mapView.region.span.latitudeDelta > mapRegion.span.latitudeDelta * 4) ||
//            (mapView.region.span.longitudeDelta > mapRegion.span.longitudeDelta * 4) ||
//            fabs(mapView.region.center.latitude - mapRegion.center.latitude) > mapRegion.span.latitudeDelta ||
//            fabs(mapView.region.center.longitude - mapRegion.center.longitude) > mapRegion.span.longitudeDelta) {
//            
//          //  manuallyChangingMap = true
//            mapView.setRegion(mapRegion, animated: true)
//            // manuallyChangingMap = false
//        }
//    }
    
   func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        if /* !manuallyChangingMap && */ ((mapView.region.span.latitudeDelta > mapRegion.span.latitudeDelta * 4) ||
//            (mapView.region.span.longitudeDelta > mapRegion.span.longitudeDelta * 4) ||
//            fabs(mapView.region.center.latitude - mapRegion.center.latitude) > mapRegion.span.latitudeDelta ||
//            fabs(mapView.region.center.longitude - mapRegion.center.longitude) > mapRegion.span.longitudeDelta) {
//         mapView.setRegion(mapRegion, animated: true)
//        }
        print("the Region has changed!")
    }
    
    func swipeToAuthPage(gestureRecognizer: UISwipeGestureRecognizer){
        let authController = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        print("swiped2")
        self.present(authController, animated: true)
    }
}

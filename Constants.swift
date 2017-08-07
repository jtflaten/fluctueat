//
//  Constants.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/14/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import MapKit


    struct MapConstants {
        let houstonCenterLat: CLLocationDegrees = 29.7604
        let houstonCenterLong: CLLocationDegrees = -95.3698
        static let houstonCenter = CLLocationCoordinate2D(latitude: 29.7604, longitude: -95.3698)
        static let mapRangeSpan = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        
        
    }
struct user {
    var latitude: Double
    var longitude: Double
    
}

struct dbConstants {
    static let truckImage = "truckImage"
    static let name = "name"
    static let description = "description"
    static let lat = "lat"
    static let long = "long"
    static let pictures = "pictures"
    static let open = "open"
    static let openUntil = "openUntil"
}

let maxNumberOfFoodImages = 6
let vendorCoreData = "VendorCD"
let truckPhotoString = "TruckPhoto"
let foodPhotoString = "FoodPhoto"

var currentUser = user(latitude: MapConstants.houstonCenter.longitude, longitude: MapConstants.houstonCenter.longitude)


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

struct userPlace {
    var latitude: Double
    var longitude: Double
    
}

struct dbConstants {
    static let uid = "uid"
    static let truckImage = "truckImage"
    static let name = "name"
    static let description = "description"
    static let lat = "lat"
    static let long = "long"
    static let pictures = "pictures"
    static let open = "open"
    static let closingTime = "closingTime"
    static let totalTimeOpen = "totalTimeOpen"
    static let truckImageUrl = "truckImageUrl"
    
    static let foodPhotoZero = "foodPhotoZero"
    static let foodPhotoOne = "foodPhotoOne"
    static let foodPhotoTwo = "foodPhotoTwo"
    static let foodPhotoThree = "foodPhotoThree"
    static let foodPhotoFour = "foodPhotoFour"
    static let foodPhotoFive = "foodPhotoFive"
    
    static let vendorUpdate = "vendor_update"
    static let authorizedIDs = "authorized_vendors"
}

let maxNumberOfFoodImages = 6
let vendorCoreData = "VendorCD"
let truckPhotoString = "TruckPhoto"
let foodPhotoString = "FoodPhoto"

var tempUrlVariable: String?

var globalUserPlace = userPlace(latitude: MapConstants.houstonCenter.longitude, longitude: MapConstants.houstonCenter.longitude)


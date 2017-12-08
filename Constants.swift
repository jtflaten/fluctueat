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
        static let mapRangeSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.4)
        
        
    }
//USER LOCATION
struct userPlace {
    var latitude: Double
    var longitude: Double
    
}
// this variable is going to hold the user's location as soon as the CoreLocation is entered. if there is problem getting the location, it's set to the center of Houston.
var globalUserPlace = userPlace(latitude: MapConstants.houstonCenter.latitude, longitude: MapConstants.houstonCenter.longitude)

//FIREBASE
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
    
    static let foodPhoto = "foodPhoto"
    static let foodPhotoZero = "foodPhotoZero"
    static let foodPhotoOne = "foodPhotoOne"
    static let foodPhotoTwo = "foodPhotoTwo"
    static let foodPhotoThree = "foodPhotoThree"
    static let foodPhotoFour = "foodPhotoFour"
    static let foodPhotoFive = "foodPhotoFive"
    
    static let vendorUpdate = "vendor_update"
    static let authorizedIDs = "authorized_vendors"
    static let vendorArchive = "vendor_archive"
    static let openVendors = "open_vendors"
}

struct alertStrings {
    static let badUidAlert = "Uh-oh"
    static let badUidMessage = "Looks like you're not an authorized Vendor. please contact us at customer support to get that fixed up."
    static let ok = "OK"
    
    static let badNetwork = "Network Problem"
    static let notConnected = "There was a problem connecting to the internet"
    
}

let hackerDict: [Int: String] = [
    0 : dbConstants.foodPhotoZero,
    1 : dbConstants.foodPhotoOne,
    2 : dbConstants.foodPhotoTwo,
    3 : dbConstants.foodPhotoThree,
    4 : dbConstants.foodPhotoFour,
    5 : dbConstants.foodPhotoFive
]

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

let maxNumberOfFoodImages = 6
//let vendorCoreData = "VendorCD"
let truckPhotoString = "TruckPhoto"
let foodPhotoString = "FoodPhoto"

var tempUrlVariable: String?

struct MapColors {
    static let bluish = UIColor(red:0.41, green:0.64, blue:0.85, alpha:1.0)
    static let purpgray = UIColor(red:0.46, green:0.41, blue:0.52, alpha:1.0)
    static let  maroon = UIColor(red:0.37, green:0.10, blue:0.22, alpha:1.0)
    static let teal = UIColor(red:0.45, green:0.93, blue:0.86, alpha:1.0)
}



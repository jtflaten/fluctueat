//
//  Vendor.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/7/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit

struct Vendor {
    var  uniqueKey: String?
    var isAuthorizedVendor = false
    var hasAttemptedLogin = false
    var truckImage: UIImage?
    var name: String?
    var description: String?
    var lat: Double
    var long: Double
    var pictures: [UIImage?]
    var truckPhotoUrl: String
    var foodPhotoUrls: [String:String]


    init (uniqueKey: String?, truckImage: UIImage?, name: String?, description: String?, pictures: [UIImage], open: Bool, truckPhotoUrl: String, foodPhotoUrls: [String:String]) {
        self.uniqueKey = uniqueKey
        self.truckImage = truckImage
        self.name = name
        self.description = description
        self.lat = globalUserPlace.latitude
        self.long = globalUserPlace.longitude
        self.pictures = pictures
        self.truckPhotoUrl = truckPhotoUrl
        self.foodPhotoUrls = foodPhotoUrls
    }
    
    init (uniqueKey: String?, truckImage: UIImage?, name: String?, description: String?, pictures: [UIImage?], open: Bool, truckPhotoUrl: String, foodPhotoUrls: [String:String], lat: Double, long: Double) {
        self.uniqueKey = uniqueKey
        self.truckImage = truckImage
        self.name = name
        self.description = description
        self.lat = lat
        self.long = long
        self.pictures = pictures
        self.truckPhotoUrl = truckPhotoUrl
        self.foodPhotoUrls = foodPhotoUrls
    }
    
}


let testVendor: Vendor = {
    let testOne = Vendor(uniqueKey: defaultKey, truckImage: #imageLiteral(resourceName: "jakes_truck"), name: "Gorumet Sorbet", description: "Out of Sorbet, try some other stuff!", pictures: [#imageLiteral(resourceName: "blackened_ranch"),#imageLiteral(resourceName: "cookies"), #imageLiteral(resourceName: "corn_bowl"), #imageLiteral(resourceName: "nugget"), #imageLiteral(resourceName: "pepper"), #imageLiteral(resourceName: "sammich")], open: true, truckPhotoUrl: defaultKey, foodPhotoUrls: [dbConstants.foodPhotoZero:defaultKey])
    
    return testOne
}()

let emptyFoodImages = [#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),]
let emptyDict = [#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty")]
let emptyTruckImage: UIImage = #imageLiteral(resourceName: "empty")
let defaultName = "What's the name of your food truck?"
let defaultDesc = "What type of food do you serve?"
let defaultKey = "empty"
let vacantImageUrl = "gs://fluctueat-ccc9d.appspot.com/vacant/empty.png"


var userVendor = Vendor(uniqueKey: defaultKey, truckImage: emptyTruckImage, name: defaultName, description: defaultDesc, pictures: emptyDict, open: false, truckPhotoUrl: vacantImageUrl, foodPhotoUrls: [dbConstants.foodPhotoZero:vacantImageUrl,dbConstants.foodPhotoOne:vacantImageUrl,dbConstants.foodPhotoTwo:vacantImageUrl,dbConstants.foodPhotoThree:vacantImageUrl,dbConstants.foodPhotoFour:vacantImageUrl,dbConstants.foodPhotoFive:vacantImageUrl])


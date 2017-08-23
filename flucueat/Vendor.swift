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
    var truckImage: UIImage?
    var name: String?
    var description: String?
    var lat: Double
    var long: Double
    var pictures: [UIImage]

    var truckPhotoUrl: String
    var foodPhotoUrls: [String]

    init (uniqueKey: String?, truckImage: UIImage?, name: String?, description: String?, pictures: [UIImage], open: Bool, closingTime: Date? , timeUntilCloseFromOpen: TimeInterval, truckPhotoUrl: String, foodPhotoUrls: [String]) {
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
    
    init(key: String, CDVendor: VendorCD, truckImage: TruckPhoto, foodPhotos: [FoodPhoto]){
        self.uniqueKey = key
        self.truckImage = UIImage(data: truckImage.image! as Data)
        self.name = CDVendor.name
        self.description = CDVendor.foodDesc
        self.pictures = convertFoodPhotos(foodPhotos: foodPhotos)
        self.lat = globalUserPlace.latitude 
        self.long = globalUserPlace.longitude
        self.truckPhotoUrl = truckImage.imageUrl!
        self.foodPhotoUrls = convertFoodPhotoCDtoURL(foodPhotos: foodPhotos)
    }
    
    


    
}
func convertFoodPhotos(foodPhotos: [FoodPhoto]) -> [UIImage]  {
    var foodImages = [UIImage]()
    for photo in foodPhotos {
        foodImages.append(UIImage(data: photo.image! as Data)!)
    }
    return foodImages
}
func convertFoodPhotoCDtoURL(foodPhotos: [FoodPhoto]) -> [String]  {
    var foodImageUrls = [String]()
    for photo in foodPhotos {
    foodImageUrls.append(photo.imageUrl!)
    }
    return foodImageUrls
}


let testVendor: Vendor = {
    let testOne = Vendor(uniqueKey: defaultKey, truckImage: #imageLiteral(resourceName: "jakes_truck"), name: "Gorumet Sorbet", description: "Out of Sorbet, try some other stuff!", pictures: [#imageLiteral(resourceName: "blackened_ranch"),  #imageLiteral(resourceName: "cookies"),  #imageLiteral(resourceName: "corn_bowl"),  #imageLiteral(resourceName: "nugget"),  #imageLiteral(resourceName: "pepper"),  #imageLiteral(resourceName: "sammich")], open: true, closingTime: Date() , timeUntilCloseFromOpen: 6000, truckPhotoUrl: defaultKey, foodPhotoUrls: [defaultKey])
    
    return testOne
}()

let emptyDict = [#imageLiteral(resourceName: "empty"),  #imageLiteral(resourceName: "empty"), #imageLiteral(resourceName: "empty"), #imageLiteral(resourceName: "empty"), #imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty")]
let emptyTruckImage: UIImage = #imageLiteral(resourceName: "empty")
let defaultName = "What's the name of your food truck?"
let defaultDesc = "What type of food do you serve?"
let defaultKey = "empty"
let vacantImageUrl = "gs://fluctueat-ccc9d.appspot.com/vacant/empty.png"


var userVendor = Vendor(uniqueKey: defaultKey, truckImage: emptyTruckImage, name: defaultName, description: defaultDesc, pictures: emptyDict, open: false,  closingTime: nil, timeUntilCloseFromOpen: 6000 , truckPhotoUrl: defaultKey, foodPhotoUrls: [])

struct VendorTime {
    var open: Bool
    var closingTime: Date? //FiX this! should be a date or time
    var timeUntilCloseFromOpen: TimeInterval?
}


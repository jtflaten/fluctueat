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
    //var uniqueKey: String?
    var truckImage: UIImage?
    var name: String?
    var description: String?
    var lat: Double
    var long: Double
    var pictures: [UIImage]
    var open: Bool
    var openUntil: String? //FiX this! should be a date or time

    
}

let testVendor: Vendor = {
    let testOne = Vendor(truckImage: #imageLiteral(resourceName: "jakes_truck"), name: "Gorumet Sorbet", description: "Out of Sorbet, try some other stuff!", lat: MapConstants.houstonCenter.latitude, long: MapConstants.houstonCenter.longitude, pictures: [#imageLiteral(resourceName: "blackened_ranch"), #imageLiteral(resourceName: "cookies"), #imageLiteral(resourceName: "corn_bowl"),#imageLiteral(resourceName: "nugget"),#imageLiteral(resourceName: "pepper"), #imageLiteral(resourceName: "sammich")], open: true, openUntil: "11:11")
    
    return testOne
}()

let emptyArray = [#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty")]
let emptyTruckImage: UIImage = #imageLiteral(resourceName: "empty")
let defaultName = "What's the name of your food truck?"
let defaultDesc = "What type of food do you serve?"



var userVendor = Vendor(truckImage: emptyTruckImage, name: defaultName, description: defaultDesc, lat: MapConstants.houstonCenter.latitude, long: MapConstants.houstonCenter.longitude, pictures: emptyArray, open: false, openUntil: nil)
    



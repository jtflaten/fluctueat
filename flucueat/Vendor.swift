//
//  Vendor.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/7/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation

struct Vendor {
    var uniqueKey: String?
    var name: String?
    var description: String?
    var lat: Double?
    var long: Double?
    var pictures: [String: String?]?
    var open: Bool
    var openUntil: String? //FiX this! should be a date or time
    
}

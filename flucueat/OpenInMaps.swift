//
//  OpenInMaps.swift
//  fluctueat
//
//  Created by Jake Flaten on 10/11/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import UIKit

func getDirections(lat: Double, long: Double, vc: UIViewController) {
    let coordinates = "\(lat),\(long)"
    let googleUrlScheme = "https://www.google.com/maps/search/?api=1&query=\(coordinates)"
    let app = UIApplication.shared
    if let toOpen = URL(string: googleUrlScheme) {
        guard app.canOpenURL(toOpen) else {
            vc.alertView(title: "Something's gone wrong", message: "We can't open up a Maps App", dismissAction: "Ok")
            return
        }
        app.open(toOpen, options: [:], completionHandler: nil)
        }
    print(googleUrlScheme)
}



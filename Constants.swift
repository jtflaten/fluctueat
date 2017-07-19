//
//  Constants.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/14/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import MapKit

extension HomeMapViewController{
    struct MapConstants {
        let houstonCenterLat: CLLocationDegrees = 29.7604
        let houstonCenterLong: CLLocationDegrees = -95.3698
        static let houstonCenter = CLLocationCoordinate2D(latitude: 29.7604, longitude: -95.3698)
        static let mapRangeSpan = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        
        
    }
}

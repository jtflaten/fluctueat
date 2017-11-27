//
//  MarkerViews.swift
//  fluctueat
//
//  Created by Jake Flaten on 11/26/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import MapKit

class MarkerView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            image = resizeImage(#imageLiteral(resourceName: "mapTruck"))
            
            if annotation?.title! == "This is You"{
                image = resizeImage(#imageLiteral(resourceName: "mapPerson"))
            }
        }
        
       
        
    }
}

func resizeImage(_ image: UIImage) -> UIImage {
    let size = CGSize(width: 32, height: 44)
    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
     return resizedImage!
}

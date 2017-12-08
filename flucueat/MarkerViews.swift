//
//  MarkerViews.swift
//  fluctueat
//
//  Created by Jake Flaten on 11/26/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import MapKit

@available(iOS 11.0, *)
class MarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
           // calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            //image = resizeImage(#imageLiteral(resourceName: "mapTruck"))
            glyphImage = #imageLiteral(resourceName: "truckGlyph")
            glyphTintColor = MapColors.maroon
            markerTintColor = MapColors.bluish
            
            if annotation?.title! == "This is You"{
                markerTintColor = MapColors.maroon
                glyphImage = #imageLiteral(resourceName: "PersonGlyph")
                glyphTintColor = MapColors.teal
                //image = resizeImage(#imageLiteral(resourceName: "mapPerson"))
            }
        }
        
       
        
    }
}

class ImageMarkerView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
           // calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
           image = resizeImage(#imageLiteral(resourceName: "mapTruck"))
            tintColor = MapColors.bluish
            
            if annotation?.title! == "This is You"{
                tintColor = MapColors.maroon
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

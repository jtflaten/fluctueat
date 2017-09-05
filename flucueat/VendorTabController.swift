//
//  VendorTabController.swift
//  
//
//  Created by Jake Flaten on 7/19/17.
//
//

import UIKit
import CoreLocation
import FirebaseAuth
import Firebase

class VendorTabController: UITabBarController, CLLocationManagerDelegate {

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseClient.sharedInstance.configureAuth(vc: self)
   //     FirebaseClient.sharedInstance().configureAuth(vc: self)
    
  
    }
}

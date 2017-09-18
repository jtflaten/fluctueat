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
        if !userVendor.isAuthorizedVendor {
         FirebaseClient.sharedInstance.loginSession(presentingVC: self)
        }
        configureSignOut()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userVendor.hasAttemptedLogin = false
        if !userVendor.isAuthorizedVendor {
            FirebaseClient.sharedInstance.checkIfVendor(vc: self)
        }
    }
    
    func configureSignOut(){
        let rightBarButton = UIBarButtonItem.init(
            title: "Sign Out",
            style: .done,
            target: self,
            action: #selector(signOutAction(sender:))
        )
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func signOutAction(sender: UIBarButtonItem) {
        print("sign out pressed")
        FirebaseClient.sharedInstance.signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
}

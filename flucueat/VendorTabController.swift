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
       // FirebaseClient.sharedInstance.configureAuth(vc: self)
       // if !userVendor.isAuthorizedVendor {
        // FirebaseClient.sharedInstance.loginSession(presentingVC: self)
      //  }
        configureSignOut()
        addFoodTruckInfoVC()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        userVendor.hasAttemptedLogin = false
//        if !userVendor.isAuthorizedVendor {
//            FirebaseClient.sharedInstance.checkIfVendor(vc: self)
//        }
    }
    
    func configureSignOut(){
        let rightBarButton = UIBarButtonItem.init(
            title: "Sign Out",
            style: .done,
            target: self,
            action: #selector(signOutAction(sender:))
        )
        
        let openButton = UIButton(type: .system)
        openButton.setImage(#imageLiteral(resourceName: "Open").withRenderingMode(.alwaysOriginal), for: .normal)
        openButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let saveButton = UIButton(type: .system)
        saveButton.setImage(#imageLiteral(resourceName: "Save") , for: .normal)
        saveButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        saveButton.addTarget(self, action: #selector(VendorInfoViewController.saveTapped), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems = [rightBarButton, UIBarButtonItem(customView: openButton), UIBarButtonItem(customView: saveButton) ]
       
    }
    
    func signOutAction(sender: UIBarButtonItem) {
        print("sign out pressed")
        FirebaseClient.sharedInstance.signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
//    func setupNavBarItems() {
//
//
//        //        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: callButton), UIBarButtonItem(customView: mapButton)]
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
//    }
    
    func addFoodTruckInfoVC(){
        let tabBarItem = UITabBarItem.init(title: "Profile", image: nil, selectedImage: nil)
        let foodTruckVC = FoodTruckInfoViewController()
        foodTruckVC.vendor = userVendor
        foodTruckVC.tabBarItem = tabBarItem
        self.viewControllers?.append(foodTruckVC)
        
    }
}

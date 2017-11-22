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
    
        configureNavBar()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    func configureNavBar(){
        
        let signOutButton = UIButton(type: .system)
        signOutButton.setImage(#imageLiteral(resourceName: "signOut").withRenderingMode(.alwaysOriginal), for: .normal)
        signOutButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        signOutButton.addTarget(self, action: #selector(signOutAction(sender:)), for: .touchUpInside)
        
        let openButton = UIButton(type: .system)
        openButton.setImage(#imageLiteral(resourceName: "Open").withRenderingMode(.alwaysOriginal), for: .normal)
        openButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        openButton.addTarget(self, action: #selector(openAction(sender:)), for: .touchUpInside)
        
        let saveButton = UIButton(type: .system)
        saveButton.setImage(#imageLiteral(resourceName: "Save") , for: .normal)
        saveButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        saveButton.addTarget(self, action: #selector(saveAction(sender:)), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: signOutButton), UIBarButtonItem(customView: saveButton), UIBarButtonItem(customView: openButton) ]
       
    }
    
 
    func addLocationToVendor() {
        userVendor.lat = globalUserPlace.latitude
        userVendor.long = globalUserPlace.longitude
        
    }
    
    func addCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(#imageLiteral(resourceName: "Close").withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        closeButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems?.remove(at: 2)
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: closeButton))
    }
    
    func addOpenButton() {
        let openButton = UIButton(type: .system)
        openButton.setImage(#imageLiteral(resourceName: "Open").withRenderingMode(.alwaysOriginal), for: .normal)
        openButton.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        openButton.addTarget(self, action: #selector(openAction(sender:)), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems?.remove(at: 2)
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: openButton))
    }
    
    func signOutAction(sender: UIButton) {
        print("sign out pressed")
        FirebaseClient.sharedInstance.signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    func openAction(sender: UIButton) {
        addLocationToVendor()
        FirebaseClient.sharedInstance.sendVendorDataForDataBase()
        addCloseButton()
    }
    
    func closeAction(sender: UIButton) {
        FirebaseClient.sharedInstance.removeFromOpenVendorDB()
        addOpenButton()
    }
    
    func saveAction(sender: UIButton) {
       addLocationToVendor()
        FirebaseClient.sharedInstance.saveVendorData()
    }
    

}

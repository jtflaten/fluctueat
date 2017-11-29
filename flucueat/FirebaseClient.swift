//
//  FirebaseClient.swift
//  fluctueat
//
//  Created by Jake Flaten on 8/7/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI


class FirebaseClient : NSObject {
    
    static let sharedInstance = FirebaseClient()
    var ref: DatabaseReference!

    var storageRef: StorageReference!
    var _refHandle: DatabaseHandle!
    let authUI = FUIAuth.defaultAuthUI()
    var _authHandle: AuthStateDidChangeListenerHandle!
    var vendorUser: User?
    var urlSring: String?
    var openVendors = [Vendor]()
    var vendorArchive = [Vendor]()
    var vendorsSnapshot = [DataSnapshot]()
    var anonUser: User?
    
    
    
    
 
    func configureAuth(vc: UIViewController) {
        _authHandle = Auth.auth().addStateDidChangeListener { ( auth: Auth?, user: User?) in
            if let activeUser = user {
                if self.vendorUser != activeUser {
                    self.vendorUser = activeUser
                    self.checkIfVendor(vc: vc)
                    userVendor = self.findCorrectVendor(id: self.vendorUser?.uid)!
                  
                } else {
                    if !userVendor.isAuthorizedVendor {
                        self.loginSession(presentingVC: vc)
                    }
                }
            }
            
            
        }
    }
    

    
    func anonSignIn(vc: HomeMapViewController) {
        Auth.auth().signInAnonymously() { (user, error) in
            guard (error == nil) else {
            vc.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                return
            }
            
            self.anonUser = user!
            self.vendorUser = user!
            
            }
        
    }
    
    func findCorrectVendor(id: String?) -> Vendor? {
        
        for vendor in FirebaseClient.sharedInstance.vendorArchive {
            
            if id == vendor.uniqueKey {
                return vendor
            }
        }
        return nil
    }
    
    func checkIfVendor(vc: UIViewController) {
        let dbPath = "authorized_vendors"
        _ = ref.child(dbPath).observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let authorizedVendors = Array(value.allValues) as! [String]
                for theValue in authorizedVendors {
                    if theValue == self.vendorUser?.uid {
                        userVendor.isAuthorizedVendor = true
                        userVendor.uniqueKey = self.vendorUser?.uid
                        
                        return
                    }
                }
                if userVendor.hasAttemptedLogin {
                    vc.alertViewWithPopToRoot(title: alertStrings.badUidAlert, message: alertStrings.badUidMessage, dismissAction: alertStrings.ok)
                } else {
                    self.loginSession(presentingVC: vc)
                }
                
            }
        })
    }
    
    func checkIfVendorAndPop(vc: UIViewController) {
        let dbPath = "authorized_vendors"
        _ = ref.child(dbPath).observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let authorizedVendors = Array(value.allValues) as! [String]
                for theValue in authorizedVendors {
                    if theValue == self.vendorUser?.uid {
                        userVendor.isAuthorizedVendor = true
                        userVendor.uniqueKey = self.vendorUser?.uid
                        
                        return
                    }
                }
                vc.alertViewWithPopToRoot(title: alertStrings.badUidAlert, message: alertStrings.badUidMessage, dismissAction: alertStrings.ok)
                
            }
        })
    }

    func configureDatabase(vc: HomeMapViewController) {
    
        ref = Database.database().reference()
        _refHandle = ref.child(dbConstants.openVendors).observe(.value, with: { (snapshot) in
           
            if let value = snapshot.value as? NSDictionary {
                self.openVendors = self.parseVendorSnapshot(snapshot: value)
                vc.makeVendorAnnotations()
            }
        })
    }
    
    func configureVendor() {
        
        ref = Database.database().reference()
        _refHandle = ref.child(dbConstants.vendorArchive).observe(.value, with: { (snapshot) in
            
            if let value = snapshot.value as? NSDictionary {
                self.vendorArchive = self.parseVendorSnapshot(snapshot: value)
            }
        })
    }
    
    func configureStorage(){
       
        storageRef = Storage.storage().reference()
    }
    
    func imageStorageUrl(url: String) -> StorageReference {
        
        return Storage.storage().reference(forURL:url)
    }
   
    
    func loginSession(presentingVC: UIViewController) {
        
        let authViewController = authUI?.authViewController()
       
        presentingVC.present(authViewController!, animated: true, completion: nil)
        userVendor.hasAttemptedLogin = true
    
    }

    func parseVendorSnapshot(snapshot: NSDictionary) -> [Vendor] {
      
        var vendorList = [Vendor]()
        
                for (_, dict) in snapshot {
                    let vendorDict = dict as! NSDictionary
    
                    let uid = vendorDict[dbConstants.uid] as! String
                    let name = vendorDict[dbConstants.name] as! String
                    let desc = vendorDict[dbConstants.description] as! String
                    let lat = Double(vendorDict[dbConstants.lat] as! String)
                    let long = Double(vendorDict[dbConstants.long] as! String)
                    let truckPhotoURL = vendorDict[dbConstants.truckImageUrl] as! String
                    let foodPhototsURL = [dbConstants.foodPhotoOne:vendorDict[dbConstants.foodPhotoOne],dbConstants.foodPhotoTwo:vendorDict[dbConstants.foodPhotoTwo], dbConstants.foodPhotoThree:vendorDict[dbConstants.foodPhotoThree], dbConstants.foodPhotoFour:vendorDict[dbConstants.foodPhotoFour], dbConstants.foodPhotoFive:vendorDict[dbConstants.foodPhotoFive], dbConstants.foodPhotoZero:vendorDict[dbConstants.foodPhotoZero]] as! [String: String]
                    let newVendor = Vendor(uniqueKey: uid, truckImage: nil, name: name, description: desc, pictures: emptyFoodImages, open: true,  truckPhotoUrl: truckPhotoURL, foodPhotoUrls: foodPhototsURL, lat: lat!, long :long!)
                    vendorList.append(newVendor)
                }
                print(vendorList)
        
            return vendorList
        
           }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard (error == nil) else {
            print(error.debugDescription)
            return
        }

        self.loginSession(presentingVC: authUI.authViewController())
    }
    
    func sendTruckPhotoToFirebase(photoData: Data, vc: VendorInfoViewController) {
        _ = UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let imagePath = "\(userVendor.uniqueKey!)/truck_photos"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef!.child(imagePath).putData(photoData, metadata: metadata){ (metadata, error) in
            if let error = error {
                print(" error uploading: \(error)")
                vc.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                _ = UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            userVendor.truckPhotoUrl = self.storageRef!.child((metadata?.path)!).description
            _ = UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
        
    }
    
    func downloadPhotos(vendor: Vendor) -> UIImage {
        var truckImage: UIImage = #imageLiteral(resourceName: "empty")
        let imageUrl = vendor.truckPhotoUrl
        Storage.storage().reference(forURL: imageUrl).getData(maxSize: INT64_MAX) { (data, error) in
            guard (error == nil) else {
                print(error.debugDescription)
                
                return
            }
            if  let downloadedImage = UIImage.init(data: data!, scale: 100) {
            truckImage = downloadedImage
            }
        }
               return truckImage
    }
    
    func sendFoodPhotoToFireBase(photoData: Data, key: String, vc: VendorInfoViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let imagePath = "\(userVendor.uniqueKey!)/food_photos/\(key)"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print(" error uploading: \(error)")
                vc.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
                
            }
            userVendor.foodPhotoUrls[key] = self.storageRef!.child((metadata?.path)!).description
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

           
        }
    }
    
    
    func sendVendorDataForDataBase() {
        var data = [String:String]()
        data[dbConstants.uid] = userVendor.uniqueKey
        data[dbConstants.name] = userVendor.name
        data[dbConstants.description] = userVendor.description
        data[dbConstants.lat] = "\(userVendor.lat)"
        data[dbConstants.long] = "\(userVendor.long)"
        data[dbConstants.truckImageUrl] = userVendor.truckPhotoUrl
        
        data[dbConstants.foodPhotoZero] = userVendor.foodPhotoUrls[dbConstants.foodPhotoZero]
        data[dbConstants.foodPhotoOne] = userVendor.foodPhotoUrls[dbConstants.foodPhotoOne]
        data[dbConstants.foodPhotoTwo] = userVendor.foodPhotoUrls[dbConstants.foodPhotoTwo]
        data[dbConstants.foodPhotoThree] = userVendor.foodPhotoUrls[dbConstants.foodPhotoThree]
        data[dbConstants.foodPhotoFour] = userVendor.foodPhotoUrls[dbConstants.foodPhotoFour]
        data[dbConstants.foodPhotoFive] = userVendor.foodPhotoUrls[dbConstants.foodPhotoFive]
        
        ref.child(dbConstants.vendorArchive).child(userVendor.uniqueKey!).setValue(data)
        ref.child(dbConstants.openVendors).child(userVendor.uniqueKey!).setValue(data)
    }
    
    func removeFromOpenVendorDB() {
        ref.child(dbConstants.openVendors).child(userVendor.uniqueKey!).removeValue()
    }
    
    func saveVendorData () {
        var data = [String:String]()
        data[dbConstants.uid] = userVendor.uniqueKey
        data[dbConstants.name] = userVendor.name
        data[dbConstants.description] = userVendor.description
        data[dbConstants.lat] = "\(userVendor.lat)"
        data[dbConstants.long] = "\(userVendor.long)"
        data[dbConstants.truckImageUrl] = userVendor.truckPhotoUrl
        
        data[dbConstants.foodPhotoZero] = userVendor.foodPhotoUrls[dbConstants.foodPhotoZero]
        data[dbConstants.foodPhotoOne] = userVendor.foodPhotoUrls[dbConstants.foodPhotoOne]
        data[dbConstants.foodPhotoTwo] = userVendor.foodPhotoUrls[dbConstants.foodPhotoTwo]
        data[dbConstants.foodPhotoThree] = userVendor.foodPhotoUrls[dbConstants.foodPhotoThree]
        data[dbConstants.foodPhotoFour] = userVendor.foodPhotoUrls[dbConstants.foodPhotoFour]
        data[dbConstants.foodPhotoFive] = userVendor.foodPhotoUrls[dbConstants.foodPhotoFive]
        
        ref.child(dbConstants.vendorArchive).child(userVendor.uniqueKey!).setValue(data)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out:", signOutError)
        }
        self.vendorUser = anonUser
        userVendor.isAuthorizedVendor = false
        userVendor.hasAttemptedLogin = false
    }
    
    func getVacantImageUrl() -> String {
        let imagePath = "vacant/empty.png"
        let imageUrl = storageRef!.child(imagePath).description
        
        return imageUrl
    }
    

  
   
    
   
}

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
    
 //   static var user = User()
    static let sharedInstance = FirebaseClient()
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var _refHandle: DatabaseHandle!
    let authUI = FUIAuth.defaultAuthUI()
    var _authHandle: AuthStateDidChangeListenerHandle!
    var vendorUser: User?
    var urlSring: String?
    var openVendors = [Vendor]()
    var vendorsSnapshot = [DataSnapshot]()
    
    
    
    
 
    func configureAuth(vc: UIViewController) {
        _authHandle = Auth.auth().addStateDidChangeListener { ( auth: Auth?, user: User?) in
            if let activeUser = user {
                if self.vendorUser != activeUser {
                    self.vendorUser = activeUser
                    self.checkIfVendor(vc: vc)
                  
                } else {
                    
                    self.loginSession(presentingVC: vc)
                }
            }
        }
    }
    
    func anonSignIn() {
        Auth.auth().signInAnonymously() { (user, error) in
         //   let isAnonymous = user!.isAnonymous
           self.vendorUser = user!
            }
        
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
                        print("authorizedAtFirst")
                        return
                    }
                print("checkedAuth")
                    
                }
                print("notAUTHOrized")
               
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
           
            print(snapshot)
        })
        print(vendorsSnapshot)
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
        
    
    }
    
    func parseVendorSnapshot(snapshot: NSDictionary) -> [Vendor] {
       var vendorList = [Vendor]()
        
                for (vendor, dict) in snapshot {
                    let vendorDict = dict as! NSDictionary
    
                    let uid = vendorDict[dbConstants.uid] as! String
                    let name = vendorDict[dbConstants.name] as! String
                    let desc = vendorDict[dbConstants.description] as! String
                    let lat = Double(vendorDict[dbConstants.lat] as! String)
                    let long = Double(vendorDict[dbConstants.long] as! String)
                    let truckPhotoURL = vendorDict[dbConstants.truckImageUrl] as! String
                    let foodPhototsURL = [vendorDict[dbConstants.foodPhotoOne],vendorDict[dbConstants.foodPhotoTwo], vendorDict[dbConstants.foodPhotoThree], vendorDict[dbConstants.foodPhotoFour], vendorDict[dbConstants.foodPhotoFive], vendorDict[dbConstants.foodPhotoZero]] as! [String]
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
        vendorUser = user
        self.loginSession(presentingVC: authUI.authViewController())
    }
    
    func sendTruckPhotoToFirebase(photoData: Data, vc: VendorInfoViewController) {
        let imagePath = "\(userVendor.uniqueKey!)/truck_photos"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef!.child(imagePath).putData(photoData, metadata: metadata){ (metadata, error) in
            if let error = error {
                print(" error uploading: \(error)")
                return
            }
            userVendor.truckPhotoUrl = self.storageRef!.child((metadata?.path)!).description
            vc.deleteOldTruckImage()
            vc.createTruckImageCD(truckImage: UIImage(data: photoData)!, url: self.storageRef!.child((metadata?.path)!).description )
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
    
    func sendFoodPhotoToFireBase(photoData: Data, indexPath: Int, vc: VendorInfoViewController) {
        let imagePath = "\(userVendor.uniqueKey!)/food_photos/\(indexPath)"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print(" error uploading: \(error)")
                return
            }
            userVendor.foodPhotoUrls.insert(self.storageRef!.child((metadata?.path)!).description, at: indexPath)
            userVendor.foodPhotoUrls.remove(at: indexPath + 1)
         
            vc.deleteSinglePhotoAlt(index: indexPath)
           
            vc.createFoodImageCD(image: UIImage(data: photoData)!, url: (self.storageRef!.child((metadata?.path)!).description))

           
        }
    }
    
    
    func sendVendorDataForDataBase(closingTime: String , totalTimeOpen: String ) {
        var data = [String:String]()
        data[dbConstants.uid] = userVendor.uniqueKey
        data[dbConstants.name] = userVendor.name
        data[dbConstants.description] = userVendor.description
        data[dbConstants.lat] = "\(userVendor.lat)"
        data[dbConstants.long] = "\(userVendor.long)"
        data[dbConstants.closingTime] = closingTime
        data[dbConstants.totalTimeOpen] = totalTimeOpen
        data[dbConstants.truckImageUrl] = userVendor.truckPhotoUrl
        
        data[dbConstants.foodPhotoZero] = userVendor.foodPhotoUrls[0]
        data[dbConstants.foodPhotoOne] = userVendor.foodPhotoUrls[1]
        data[dbConstants.foodPhotoTwo] = userVendor.foodPhotoUrls[2]
        data[dbConstants.foodPhotoThree] = userVendor.foodPhotoUrls[3]
        data[dbConstants.foodPhotoFour] = userVendor.foodPhotoUrls[4]
        data[dbConstants.foodPhotoFive] = userVendor.foodPhotoUrls[5]
        
      
        ref.child(dbConstants.vendorArchive).child(userVendor.uniqueKey!).setValue(data)
        ref.child(dbConstants.openVendors).child(userVendor.uniqueKey!).setValue(data)
    }
    
    func removeFromOpenVendorDB() {
        ref.child(dbConstants.openVendors).child(userVendor.uniqueKey!).removeValue()
    }
    

    
    func getVacantImageUrl() -> String {
        let imagePath = "vacant/empty.png"
        let imageUrl = storageRef!.child(imagePath).description
        
        return imageUrl
    }
    

  
   
    
   
}

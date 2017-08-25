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
    var _authHandle: AuthStateDidChangeListenerHandle!
    var vendorUser: User?
    var urlSring: String?
    
    
    
 
    func configureAuth(vc: VendorInfoViewController) {
        _authHandle = Auth.auth().addStateDidChangeListener { ( auth: Auth?, user: User?) in
            if let activeUser = user {
                if self.vendorUser != activeUser {
                    self.vendorUser = activeUser
                    vc.signedInStatus(isSignedIn: true)
                } else {
                    vc.signedInStatus(isSignedIn: false)
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
                        print("authorizedAtFirst")
                        return
                    }
                print("checkedAuth")
                    
                }
                print("notAUTHOrized")
                    self.loginSession(presentingVC: vc)
            }
        })
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func configureStorage(){
        storageRef = Storage.storage().reference()
    }
    
   
    
    func loginSession(presentingVC: UIViewController) {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        presentingVC.present(authViewController, animated: true, completion: nil)
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
            vc.createTruckImageCD(truckImage: UIImage(data: photoData)!, url: self.storageRef!.child((metadata?.path)!).description )
        }
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
            print(12)
            vc.deleteSinglePhotoAlt(index: indexPath)
            print(34)
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
        
        data[dbConstants.foodPhotoZero] = userVendor.foodPhotoUrls[1]
        data[dbConstants.foodPhotoOne] = userVendor.foodPhotoUrls[2]
        data[dbConstants.foodPhotoTwo] = userVendor.foodPhotoUrls[3]
        data[dbConstants.foodPhotoThree] = userVendor.foodPhotoUrls[4]
        data[dbConstants.foodPhotoFour] = userVendor.foodPhotoUrls[5]
        data[dbConstants.foodPhotoFive] = userVendor.foodPhotoUrls[6]
        
        ref.child(dbConstants.vendorUpdate).childByAutoId().setValue(data)
    }
    
    func getVacantImageUrl() -> String {
        let imagePath = "vacant/empty.png"
        let imageUrl = storageRef!.child(imagePath).description
        
        return imageUrl
    }
    
//    class func sharedInstance() -> FirebaseClient {
//        struct Singleton {
//            static var sharedInstance = FirebaseClient()
//        }
//        return Singleton.sharedInstance
//    }
    
  
   
    
   
}

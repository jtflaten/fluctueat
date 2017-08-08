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
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var _refHandle: DatabaseHandle!
    var _authHandle: AuthStateDidChangeListenerHandle!
    var vendorUser: User?
    
    
 
    func configureAuth(vc: UIViewController) {
        _authHandle = Auth.auth().addStateDidChangeListener { ( auth: Auth?, user: User?) in
            if let activeUser = user {
                if self.vendorUser != activeUser {
                    self.vendorUser = activeUser
                    self.signedInStatus(isSignedIn: true)
                } else {
                    self.signedInStatus(isSignedIn: false)
                    self.loginSession(presentingVC: vc)
                }
            }
        }
    }
    
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func configureStorage(){
        storageRef = Storage.storage().reference()
    }
    
    func signedInStatus(isSignedIn: Bool){
        //TODO addstuff for if the user is signed in here
        
        if (isSignedIn) {
            configureDatabase()
            userVendor.uniqueKey = self.vendorUser?.uid
        }
    }
    
    func loginSession(presentingVC: UIViewController) {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        presentingVC.present(authViewController, animated: true, completion: nil)
    }
    
    func sendTruckPhotoToFirebase(photoData: Data) {
        let imagePath = "\(userVendor.uniqueKey!)/truck_photos"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef!.child(imagePath).putData(photoData, metadata: metadata){ (metadata, error) in
            if let error = error {
                print(" error uploading: \(error)")
                return
            }
            userVendor.truckPhotoUrl = self.storageRef!.child((metadata?.path)!).description
        }
    }
    
    func sendFoodPhotoToFireBase(photoData: Data, indexPath: Int) {
        let imagePath = "\(userVendor.uniqueKey!)/food_photos/\(indexPath)"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print(" error uploading: \(error)")
                return
            }
            if !userVendor.foodPhotoUrls.contains(self.storageRef!.child((metadata?.path)!).description){
                 userVendor.foodPhotoUrls.append( self.storageRef!.child((metadata?.path)!).description)
            }
           
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
    
    class func sharedInstance() -> FirebaseClient {
        struct Singleton {
            static var sharedInstance = FirebaseClient()
        }
        return Singleton.sharedInstance
    }
    
  
   
    
   
}

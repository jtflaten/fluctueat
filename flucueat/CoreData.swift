//
//  CoreData.swift
//  fluctueat
//
//  Created by Jake Flaten on 8/22/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import CoreData

extension VendorInfoViewController {
    //CORE DATA
   //  let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //CREATE OBJECTS
    func createVendorCD(name: String, foodDesc: String){
        //make the vendor for Core Data
        
        deleteAllCoreData(entity: vendorCoreData)
        
        
        let entity = NSEntityDescription.entity(forEntityName: "VendorCD", in: managedContext)!
        let vendorCD = VendorCD(entity: entity, insertInto: managedContext)
        vendorCD.setValue(name, forKeyPath: "name")
        vendorCD.setValue(foodDesc, forKeyPath: "foodDesc")
        self.foodTruck = vendorCD
        print(vendorCD.foodDesc ?? "didn't save right")
        saveInfo()
        
        
        print("we out here")
        
    }
    
    func createTruckImageCD(truckImage: UIImage, url: String) {
        let truckImagePhotoData = UIImageJPEGRepresentation(truckImage, 1)
        let truckPhotoEntity = NSEntityDescription.entity(forEntityName: "TruckPhoto", in: managedContext)!
        let truckPhoto = TruckPhoto(entity: truckPhotoEntity, insertInto: managedContext)
        truckPhoto.setValue(truckImagePhotoData!, forKeyPath: "image")
        truckPhoto.setValue(self.foodTruck, forKeyPath: "vendor")
        truckPhoto.setValue(url, forKey: "imageUrl")
        saveInfo()
    }
    
    func createFoodImageCD(image: UIImage, url: String) {
        let foodImagePhotoData = UIImageJPEGRepresentation(image, 1)
        let foodPhotoEntity = NSEntityDescription.entity(forEntityName: "FoodPhoto", in: managedContext)!
        let foodPhoto = FoodPhoto(entity: foodPhotoEntity, insertInto: managedContext)
        foodPhoto.setValue(foodImagePhotoData!, forKeyPath: "image")
        foodPhoto.setValue(self.foodTruck, forKeyPath: "vendor")
        foodPhoto.setValue(url, forKey: "imageUrl")
        saveInfo()
    }
    
  
    
    //SAVE
    
    func saveInfo() {
        do {
            try managedContext.save()
            
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    //DELETE
    
    func deleteAllCoreData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
                
            }
        } catch let error as NSError{
            print("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deleteOldTruckImage() {
        deleteAllCoreData(entity: "TruckPhoto")
    }
    
    func deleteSinglePhotoAlt(index: Int) {
        if savedImageArray.indices.contains(index) {
            managedContext.delete(savedImageArray[index])
        }
    }
    
    func deleteSingleFoodPhoto(entity: String, foodPhoto: FoodPhoto) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let predicate = NSPredicate(format: "FoodPhoto = %@", foodPhoto)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
                
            }
        } catch let error as NSError{
            print("could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    //FETCH
    func fetchTruckInfo() {
        
        
        let truckFetchRequest = NSFetchRequest<VendorCD>(entityName:"VendorCD")
        do {
            
            let fetchedArray = try managedContext.fetch(truckFetchRequest)
            if fetchedArray != [] {
                foodTruck = fetchedArray[0]
                userVendor.name = fetchedArray[0].name
                userVendor.description = fetchedArray[0].foodDesc
                
            } else {
                createVendorCD(name: userVendor.name!, foodDesc: userVendor.description!)            }
            
        } catch let error as NSError {
            print("could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func fetchTruckPhoto(){
        
        let truckImageFetchRequest = NSFetchRequest<TruckPhoto>(entityName: "TruckPhoto")
        
        do {
            let  fetchedImage = try managedContext.fetch(truckImageFetchRequest)
            if fetchedImage != []{
                foodTruckFetchedImage = fetchedImage[0]
                userVendor.truckImage = UIImage(data: (foodTruckFetchedImage!.image! as Data))
                userVendor.truckPhotoUrl = foodTruckFetchedImage!.imageUrl!
                
            }
        } catch let error as NSError {
            print("could not fetch truck image. \(error), \(error.userInfo)")
            
        }
    }
    
    
    func fetchMenuPhotos(){
        let menuImageFetchRequest = NSFetchRequest<FoodPhoto>(entityName:"FoodPhoto")
        
        do {
            let fetchedMenu = try managedContext.fetch(menuImageFetchRequest)
            if fetchedMenu != [] {
                savedImageArray = fetchedMenu
                
                var imageArray = [UIImage]()
                var urlArray = [String]()
                for foodPhoto in fetchedMenu {
                    if let image = UIImage(data: foodPhoto.image! as Data) {
                        imageArray.append(image)
                        urlArray.append(foodPhoto.imageUrl!)
                    }
                }
                
                
                userVendor.pictures = imageArray
                userVendor.foodPhotoUrls = urlArray
                while userVendor.foodPhotoUrls.count < 6 {
                    self.fillIncompleteMenuFetch()
                }
            }
            
        } catch let error as NSError {
            print("could not fetch truck image. \(error), \(error.userInfo)")
        }
        
    }

}

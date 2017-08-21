//
//  VendorInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/18/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuthUI


class VendorInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   // let testVendor = testVendor
    
    
    @IBOutlet weak var foodTruckImage: UIImageView!
    @IBOutlet weak var truckName: UITextField!
    @IBOutlet weak var truckDescription: UITextField!
    @IBOutlet weak var foodImageCollection: UICollectionView!
    @IBOutlet weak var foodImageCollectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var saveButton: UIButton!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var foodTruck: VendorCD?
    var foodTruckFetchedImage: TruckPhoto?
    var savedImageArray = [FoodPhoto]()
    var indexOfSelectedItem: Int?
  
   // var imageArray = [#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"), #imageLiteral(resourceName: "blackened_ranch"),#imageLiteral(resourceName: "cookies"),#imageLiteral(resourceName: "corn_bowl"),#imageLiteral(resourceName: "empty") ]
    

    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // configureStorage()
        FirebaseClient.sharedInstance.configureStorage()
        fetchTruckInfo()
        fetchTruckPhoto()
        fetchMenuPhotos()
        setuptextFields()
        setupTruckImage()
        foodImageCollection.dataSource = self
        foodImageCollection.delegate = self

        layoutCells()

        
    }
    
    
  
    
    func setupTruckImage() {
      //  foodTruckImage.image = #imageLiteral(resourceName: "jakes_truck")
        foodTruckImage.image = userVendor.truckImage!
        foodTruckImage.backgroundColor = .gray

     
    }
    
    func setuptextFields(){
        truckName.text = userVendor.name
        truckDescription.text = userVendor.description

    }
    
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (userVendor.pictures.count)// maxNumberOfFoodImages
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VendorFoodImageCollectionViewCell", for: indexPath) as! FoodImageCollectionViewCell
       
        cell.foodImage.image = userVendor.pictures[indexPath.row] //imageArray[indexPath.row]
     
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexOfSelectedItem = indexPath.row
        pickImageMenu()
        
        
        
       

 
    }
    
    func layoutCells() {
        
        
        let cellVerticalSpaicng: CGFloat = 2
        var cellWidth: CGFloat
        var cellsInRow: CGFloat
        foodImageCollectionFlowLayout.invalidateLayout()
        
        switch UIDevice.current.orientation {
        case .portrait:
            cellsInRow = 3
        case .portraitUpsideDown:
            cellsInRow = 3
        case .landscapeLeft:
            cellsInRow = 4
        case.landscapeRight:
            cellsInRow = 4
        default:
            cellsInRow = 3
        }
        cellWidth = (foodImageCollection!.frame.width / cellsInRow) - 2
        cellWidth -= cellVerticalSpaicng
        foodImageCollectionFlowLayout.itemSize.width = cellWidth
        foodImageCollectionFlowLayout.itemSize.height = cellWidth
        foodImageCollectionFlowLayout.minimumInteritemSpacing = cellVerticalSpaicng
        let actualVerticalSpacing: CGFloat = (foodImageCollection!.frame.width - (cellsInRow * cellWidth))/(cellsInRow - 1)
        foodImageCollectionFlowLayout.minimumLineSpacing = actualVerticalSpacing
        
    }
    
    
   let pickerController = UIImagePickerController()
   let pickerControllerMenu = UIImagePickerController()
   
    func pickImageFoodTruck() {
       
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
       
    }

    func pickImageMenu() {
    
        pickerControllerMenu.sourceType = .photoLibrary
        pickerControllerMenu.delegate = self
        present(pickerControllerMenu, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func changeImage(_ sender: Any) {
        pickImageFoodTruck()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if  picker == pickerController {
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                foodTruckImage.image = editedImage
               // sendTruckPhotoToFirebase(photoData: UIImageJPEGRepresentation(editedImage, 0.8)!)
                FirebaseClient.sharedInstance.sendTruckPhotoToFirebase(photoData: UIImageJPEGRepresentation(editedImage, 0.8)!)
            } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                foodTruckImage.image = originalImage
               // sendTruckPhotoToFirebase(photoData: UIImageJPEGRepresentation(originalImage, 0.8)!)
                FirebaseClient.sharedInstance.sendTruckPhotoToFirebase(photoData: UIImageJPEGRepresentation(originalImage, 0.8)!)
            } else {
                print("spmething's gone wrong")
            }
            dismiss(animated: true, completion: nil)
        
        } else if picker == pickerControllerMenu {
         
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                DispatchQueue.global(qos: .userInitiated).async {
                    let dispatchGroup = DispatchGroup()
                    userVendor.pictures.insert(originalImage, at: self.indexOfSelectedItem!)
                    userVendor.pictures.remove(at: self.indexOfSelectedItem! + 1)
                    dispatchGroup.enter()
                    FirebaseClient.sharedInstance.sendFoodPhotoToFireBase(photoData: UIImageJPEGRepresentation(originalImage, 0.8)!, indexPath: self.indexOfSelectedItem!)
                    dispatchGroup.wait()
                    self.deleteSinglePhotoAlt(index: self.indexOfSelectedItem!)
                    self.createFoodImageCD(image: originalImage, url: tempUrlVariable!, vendorCD: self.foodTruck!)
            
                }
            }
            foodImageCollection.reloadData()
            dismiss(animated: true, completion: nil)
        } else {
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func createVendorCDandImages(name: String, foodDesc: String, truckImage: UIImage, foodImages: [UIImage]){
       //make the vendor for Core Data
        
        deleteAllCoreData(entity: vendorCoreData)
        deleteAllCoreData(entity: foodPhotoString)
        deleteAllCoreData(entity: truckPhotoString)

        let entity = NSEntityDescription.entity(forEntityName: "VendorCD", in: managedContext)!
        let vendorCD = VendorCD(entity: entity, insertInto: managedContext)
        vendorCD.setValue(name, forKeyPath: "name")
        vendorCD.setValue(foodDesc, forKeyPath: "foodDesc")
        print(vendorCD.foodDesc ?? "didn't save right")
        
        
        // make the Truck Image for core data
        let truckImagePhotoData = UIImageJPEGRepresentation(truckImage, 1)
        let truckPhotoEntity = NSEntityDescription.entity(forEntityName: "TruckPhoto", in: managedContext)!
        let truckPhoto = TruckPhoto(entity: truckPhotoEntity, insertInto: managedContext)
        truckPhoto.setValue(truckImagePhotoData!, forKeyPath: "image")
        truckPhoto.setValue(vendorCD, forKeyPath: "vendor")
        truckPhoto.setValue(userVendor.truckPhotoUrl, forKey: "imageURL")
        
        //make the food photos for core data
//        for eachImage in foodImages {
//            let foodImagePhotoData = UIImageJPEGRepresentation(eachImage, 1)
//            let foodPhotoEntity = NSEntityDescription.entity(forEntityName: "FoodPhoto", in: managedContext)!
//            let foodPhoto = FoodPhoto(entity: foodPhotoEntity, insertInto: managedContext)
//            foodPhoto.setValue(foodImagePhotoData!, forKeyPath: "image")
//            foodPhoto.setValue(vendorCD, forKeyPath: "vendor")
//           
//        }
     print("we out here")
   
    }
    
    func createTruckImageCD() {
        
    }
    
    func createFoodImageCD(image: UIImage, url: String, vendorCD: VendorCD) {
        let foodImagePhotoData = UIImageJPEGRepresentation(image, 1)
        let foodPhotoEntity = NSEntityDescription.entity(forEntityName: "FoodPhoto", in: managedContext)!
        let foodPhoto = FoodPhoto(entity: foodPhotoEntity, insertInto: managedContext)
        foodPhoto.setValue(foodImagePhotoData!, forKeyPath: "image")
        foodPhoto.setValue(vendorCD, forKeyPath: "vendor")
        foodPhoto.setValue(url, forKey: "imageUrl")
    }
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        checkTextFields()
        updateUserVendor()
        createVendorCDandImages(name: truckName.text!, foodDesc: truckDescription.text!, truckImage: foodTruckImage.image!, foodImages: userVendor.pictures)
        saveInfo()
     //   sendVendorDataForDataBase()
    }
    
    func updateUserVendor() {
        userVendor.name = truckName.text
        userVendor.description = truckDescription.text
    }
    func saveInfo() {
        do {
            try managedContext.save()
            
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
      
    }
    
    
    
//    func sendVendorDataForDataBase() {
//        var data = [String:String]()
//        data[dbConstants.name] = truckName.text
//        data[dbConstants.description] = truckDescription.text
//        data[dbConstants.lat] = "\(userVendor.lat)"
//        data[dbConstants.long] = "\(userVendor.long)"
//        ref.childByAutoId().setValue(data)
//    }
    
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



    func fetchTruckInfo() {

        
        let truckFetchRequest = NSFetchRequest<VendorCD>(entityName:"VendorCD")
        do {
           
            let fetchedArray = try managedContext.fetch(truckFetchRequest)
                if fetchedArray != [] {
                    foodTruck = fetchedArray[0]
                    userVendor.name = fetchedArray[0].name
                    userVendor.description = fetchedArray[0].foodDesc
                    
//                } else {
//                    createVendorCDandImages(name: userVendor.name!, foodDesc: userVendor.description!, truckImage: userVendor.truckImage!, foodImages: userVendor.pictures)
            }
               
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
                    for foodPhoto in fetchedMenu {
                        if let image = UIImage(data: foodPhoto.image! as Data) {
                            imageArray.append(image)
                        }
                    }
                   
                    userVendor.pictures = imageArray
                }
            
        } catch let error as NSError {
                print("could not fetch truck image. \(error), \(error.userInfo)")
        }
        
    }
    
    func configureStorage(){
        storageRef = Storage.storage().reference()
    }
    
    
    func checkTextFields () {
        if (truckName.text?.isEmpty)! || (truckDescription.text?.isEmpty)! {
            showEmptyTextAlert()
        }
    }
    
//    func sendTruckPhotoToFirebase(photoData: Data) {
//        let imagePath = "truck_photos/"+userVendor.name!
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//        storageRef!.child(imagePath).putData(photoData, metadata: metadata)// { (metadata, error) in
          //  if let
 //   }
    
    
    
}






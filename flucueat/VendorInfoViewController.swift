//
//  VendorInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/18/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuthUI


class VendorInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var foodTruckImage: UIImageView!
    @IBOutlet weak var truckName: UITextField!
    @IBOutlet weak var truckDescription: UITextField!
    @IBOutlet weak var foodImageCollection: UICollectionView!
    @IBOutlet weak var foodImageCollectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var saveButton: UIButton!
    
 
   
    var foodTruck = VendorCD()
    var foodTruckFetchedImage: TruckPhoto?
    var savedImageArray = [FoodPhoto]()
    var indexOfSelectedItem: Int?
  

    

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
        fillOutImageUrlArray(array: userVendor.foodPhotoUrls)
        foodImageCollection.dataSource = self
        foodImageCollection.delegate = self
        layoutCells()

    }
    
    
  
    
    func setupTruckImage() {
      
        foodTruckImage.image = userVendor.truckImage!
        foodTruckImage.backgroundColor = .clear
     
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
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                foodTruckImage.image = originalImage
               
                FirebaseClient.sharedInstance.sendTruckPhotoToFirebase(photoData: UIImageJPEGRepresentation(originalImage, 0.8)!, vc: self)
            } else {
                print("spmething's gone wrong")
            }
            dismiss(animated: true, completion: nil)
        
        } else if picker == pickerControllerMenu {
         
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

                    userVendor.pictures.insert(originalImage, at: self.indexOfSelectedItem!)
                    userVendor.pictures.remove(at: self.indexOfSelectedItem! + 1)

                    FirebaseClient.sharedInstance.sendFoodPhotoToFireBase(photoData: UIImageJPEGRepresentation(originalImage, 0.8)!, indexPath: self.indexOfSelectedItem!, vc: self)
                
            }
            
            foodImageCollection.reloadData()
            dismiss(animated: true, completion: nil)
            
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //CORE DATA
    func createVendorCD(name: String, foodDesc: String){
       //make the vendor for Core Data
        
        deleteAllCoreData(entity: vendorCoreData)
    

        let entity = NSEntityDescription.entity(forEntityName: "VendorCD", in: managedContext)!
        let vendorCD = VendorCD(entity: entity, insertInto: managedContext)
        vendorCD.setValue(name, forKeyPath: "name")
        vendorCD.setValue(foodDesc, forKeyPath: "foodDesc")
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
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        checkTextFields()
        updateUserVendor()
        createVendorCD(name: truckName.text!, foodDesc: truckDescription.text!)
        saveInfo()
    
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
    
    
    func checkTextFields () {
        if (truckName.text?.isEmpty)! || (truckDescription.text?.isEmpty)! {
            showEmptyTextAlert()
        }
    }
    
    func fillOutImageUrlArray(array: [String]) {
        let emptyImageUrl = FirebaseClient.sharedInstance.getVacantImageUrl()
        var newArray = array
        while newArray.count < 6 {
            newArray.append(emptyImageUrl)
        }
        
        userVendor.foodPhotoUrls = newArray
    }
    
    func fillIncompleteMenuFetch() {
        createFoodImageCD(image: #imageLiteral(resourceName: "empty"), url: FirebaseClient.sharedInstance.getVacantImageUrl())
        userVendor.pictures.append(#imageLiteral(resourceName: "empty"))
        userVendor.foodPhotoUrls.append(FirebaseClient.sharedInstance.getVacantImageUrl())
    }

    
    
}






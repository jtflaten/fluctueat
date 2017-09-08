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
    @IBOutlet var dismissKeyboardRecognizer: UITapGestureRecognizer!
    
 
   
    var foodTruck = VendorCD()
    var foodTruckFetchedImage: TruckPhoto?
    var savedImageArray = [FoodPhoto]()
    var indexOfSelectedItem: Int?
    var keyboardOnScreen = false
  

    

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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
  
    
    func setupTruckImage() {
      
        foodTruckImage.image = userVendor.truckImage!
        foodTruckImage.backgroundColor = .clear
     
    }
    
    func setuptextFields(){
        self.truckName.delegate = self as? UITextFieldDelegate
        self.truckDescription.delegate = self as? UITextFieldDelegate
        truckName.text = userVendor.name
        truckDescription.text = userVendor.description

    }
    
    
    func updateUserVendor() {
        userVendor.name = truckName.text
        userVendor.description = truckDescription.text
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
    
    @IBAction func saveButtonPushed(_ sender: Any) {
        checkTextFields()
        updateUserVendor()
        createVendorCD(name: truckName.text!, foodDesc: truckDescription.text!)
        saveInfo()
        
    }
    
    @IBAction func tappedView(_ sender: Any) {
        resignTextfield()
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

    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            self.view.frame.origin.y -= self.keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            self.view.frame.origin.y += self.keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
        dismissKeyboardRecognizer.isEnabled = true
        
    }
    
    func keyboardDidHide(_ notification: Notification) {
        dismissKeyboardRecognizer.isEnabled = false
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        return ((notification as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
    }
    
    func resignTextfield() {
        if truckName.isFirstResponder {
            truckName.resignFirstResponder()
        }
        if truckDescription.isFirstResponder {
            truckDescription.resignFirstResponder()
        }
    }
}

// MARK: - FCViewController (Notifications)

extension VendorInfoViewController {
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    func subscribeToNotification(_ name: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}










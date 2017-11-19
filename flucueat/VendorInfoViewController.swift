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
    
    
    
    @IBOutlet weak var truckActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var truckImage: UIImageView!
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
       
        FirebaseClient.sharedInstance.configureStorage()
        //fetchTruckInfo()
        //fetchTruckPhoto()
        //fetchMenuPhotos()
        //FirebaseClient.sharedInstance.getUserVendor()
        setuptextFields()
        setupTruckImage()
        configureBackground()
        configureSaveButton()
        fillOutImageUrlArray(array: userVendor.foodPhotoUrls)
        foodImageCollection.dataSource = self
        foodImageCollection.delegate = self
        setupFoodImage()
        layoutCells()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
        FirebaseClient.sharedInstance.checkIfVendorAndPop(vc: self)
    }
    
    func configureSaveButton() {
        let saveButton = UIButton(type: .system)
        saveButton.setImage(#imageLiteral(resourceName: "Save") , for: .normal)
        saveButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        saveButton.addTarget(self, action: #selector(saveTapped(sender:)), for: .touchUpInside)
        
        self.tabBarController?.navigationItem.rightBarButtonItems?.remove(at: 1)
        self.tabBarController?.navigationItem.rightBarButtonItems?.insert(UIBarButtonItem(customView: saveButton), at: 1)
    }
    
    func configureBackground() {
        
        //        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red:0.90, green:0.76, blue:0.13, alpha:1.0).cgColor
        let colorBottom = UIColor(red:0.82, green:0.01, blue:0.11, alpha: 1.0).cgColor
        //
        //        backgroundGradient.colors = [colorTop, colorBottom]
        //        backgroundGradient.locations = [0.0, 1.0]
        //        backgroundGradient.frame = view.frame
        //        view.layer.insertSublayer(backgroundGradient, at: 0)
        view.layer.backgroundColor = colorTop
    }

    func setupTruckImage() {
      
        truckImage.image = #imageLiteral(resourceName: "empty")
        truckActivityIndicator.hidesWhenStopped = true
        truckActivityIndicator.startAnimating()
        isInternetAvailable() { answer in
            guard answer == true else {
                self.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                self.truckActivityIndicator.stopAnimating()
                return
            }
        }
        
        FirebaseClient.sharedInstance.imageStorageUrl(url: userVendor.truckPhotoUrl).getData(maxSize: INT64_MAX) { (data , error)  in
            guard error == nil else {
                print("error downloading: \(String(describing: error))")
                self.alertViewWithPopToRoot(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                self.truckActivityIndicator.stopAnimating()
                return
            }
            let downloadedTruck = UIImage.init(data: data!)
            DispatchQueue.main.async {
                self.truckImage.image = downloadedTruck
                self.truckActivityIndicator.stopAnimating()
            }
        }
        truckImage.layer.cornerRadius = 3.0
        truckImage.clipsToBounds = true
     
    }
    
    func setupFoodImage() {
        for (index, url) in userVendor.foodPhotoUrls.enumerated() {
            FirebaseClient.sharedInstance.imageStorageUrl(url: url).getData(maxSize: INT64_MAX) { (data, error) in
                guard error == nil else {
                    print("error downloading: \(String(describing: error))")
                    self.alertViewWithPopToRoot(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                    
                    return
                }
                let foodImage = UIImage.init(data: data!)
                DispatchQueue.main.async {
                    userVendor.pictures[index] = foodImage
                    self.foodImageCollection.reloadData()
                }
            }
            
        }
    }
    
    func setuptextFields(){
        truckName.delegate = self
        truckDescription.delegate = self
        truckName.text = userVendor.name
        truckDescription.text = userVendor.description

    }
    
    func updateUserVendor() {
        userVendor.name = truckName.text
        userVendor.description = truckDescription.text
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (userVendor.pictures.count)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
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
//        createVendorCD(name: truckName.text!, foodDesc: truckDescription.text!)
//        saveInfo()
        
    }
    
    func saveTapped(sender: UIButton) {
        checkTextFields()
        updateUserVendor()
        FirebaseClient.sharedInstance.saveVendorData()
 //       createVendorCD(name: truckName.text!, foodDesc: truckDescription.text!)
 //       saveInfo()
    }
    
    @IBAction func tappedView(_ sender: Any) {
        resignTextfield()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if  picker == pickerController {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                truckImage.image = originalImage
               
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
        
        isInternetAvailable() { answer in
            guard answer == true else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.alertView(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                return
            }
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
//        createFoodImageCD(image: #imageLiteral(resourceName: "empty"), url: FirebaseClient.sharedInstance.getVacantImageUrl())
        userVendor.pictures.append(#imageLiteral(resourceName: "empty"))
        userVendor.foodPhotoUrls.append(FirebaseClient.sharedInstance.getVacantImageUrl())
    }
    
//    func setupNavBarItems() {
//        let openButton = UIButton(type: .system)
//        openButton.setImage(#imageLiteral(resourceName: "Open").withRenderingMode(.alwaysOriginal), for: .normal)
//        openButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//        
//        let saveButton = UIButton(type: .system)
//        saveButton.setImage(#imageLiteral(resourceName: "Save") , for: .normal)
//        saveButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
//        
//        //        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: callButton), UIBarButtonItem(customView: mapButton)]
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
//    }

    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            self.view.frame.origin.y = self.keyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            self.view.frame.origin.y = 0
            
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
        dismissKeyboardRecognizer.isEnabled = true
        
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
        dismissKeyboardRecognizer.isEnabled = false
        
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
extension VendorInfoViewController: UITextFieldDelegate {
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
            textField.resignFirstResponder()
        
        return true
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










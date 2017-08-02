//
//  VendorInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/18/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

class VendorInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   // let testVendor = testVendor
    
    
    @IBOutlet weak var foodTruckImage: UIImageView!
    @IBOutlet weak var truckName: UITextField!
    @IBOutlet weak var truckDescription: UITextField!
    @IBOutlet weak var foodImageCollection: UICollectionView!
    @IBOutlet weak var foodImageCollectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var saveButton: UIButton!
    
   // var foodTruck: Vendor

   
    override func viewDidLoad() {
        super.viewDidLoad()
        setuptextFields()
        setupTruckImage()
        foodImageCollection.dataSource = self
        foodImageCollection.delegate = self

        layoutCells()
        
    }
    
    
    
    func setupTruckImage() {
      //  foodTruckImage.image = #imageLiteral(resourceName: "jakes_truck")
        foodTruckImage.backgroundColor = .gray

     
    }
    
    func setuptextFields(){
        truckName.text = "Enter The NAME of Your truck here"
        truckDescription.text = "enter a short description of your food here"
    }
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (testVendor.pictures?.count)!// maxNumberOfFoodImages
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VendorFoodImageCollectionViewCell", for: indexPath) as! FoodImageCollectionViewCell
        let imageArray = [#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"), #imageLiteral(resourceName: "blackened_ranch"),#imageLiteral(resourceName: "cookies"),#imageLiteral(resourceName: "corn_bowl"),#imageLiteral(resourceName: "empty") ]
        cell.foodImage.image = imageArray[indexPath.row]
     
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //pickImageMenu()
        
        let cell = collectionView.cellForItem(at: indexPath) as! FoodImageCollectionViewCell
        
        pickImageMenu()
        func sendCellToImagePicker(cell: FoodImageCollectionViewCell) {
            cell = cell
            return cell
        }
//        let pickerControllerMenu = UIImagePickerController()
//        pickerControllerMenu.delegate = self
//        present(pickerControllerMenu, animated: true, completion: nil)
 
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
            } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                foodTruckImage.image = originalImage
            } else {
                print("spmething's gone wrong")
            }
            dismiss(animated: true, completion: nil)
        } else if picker == pickerControllerMenu {
            foodTruckImage.image = #imageLiteral(resourceName: "cookies")
            dismiss(animated: true, completion: nil)
        } else {
            foodTruckImage.image = #imageLiteral(resourceName: "corn_bowl")
            dismiss(animated: true, completion: nil)
        }
    }
    
        
    
}






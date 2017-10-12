//
//  FoodTruckInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/21/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import Firebase

class FoodTruckInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var vendor: Vendor!
    var foodImages = [#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),#imageLiteral(resourceName: "empty"),]
    
    
    @IBOutlet weak var truckImage: UIImageView!
    
    @IBOutlet weak var truckName: UILabel!
    @IBOutlet weak var truckDescription: UILabel!
    @IBOutlet weak var foodImageCollection: UICollectionView!
    @IBOutlet weak var foodImageCollectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var truckActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodImageCollection.delegate = self
        foodImageCollection.dataSource = self
        setupLabels()
        setupTruckImage()
        setupFoodImage()
        layoutCells()
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

        FirebaseClient.sharedInstance.imageStorageUrl(url: vendor.truckPhotoUrl).getData(maxSize: INT64_MAX) { (data , error)  in
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
        
    }
    
    func setupFoodImage() {
        for (index, url) in vendor.foodPhotoUrls.enumerated() {
            FirebaseClient.sharedInstance.imageStorageUrl(url: url).getData(maxSize: INT64_MAX) { (data, error) in
                guard error == nil else {
                    print("error downloading: \(String(describing: error))")
                    self.alertViewWithPopToRoot(title: alertStrings.badNetwork, message: alertStrings.notConnected, dismissAction: alertStrings.ok)
                    
                    return
                }
                let foodImage = UIImage.init(data: data!)
                DispatchQueue.main.async {
                    self.vendor.pictures[index] = foodImage
                    self.foodImageCollection.reloadData()
                }
            }
            
        }
    }
    
    func setupLabels() {
        truckName.text = self.vendor.name ?? "party time"
        truckDescription.text = self.vendor.description ?? "this is a truck"
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6//(self.vendor.pictures.count)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodImageCollectionViewCell", for: indexPath) as! FoodImageCollectionViewCell
        
        cell.foodCellAcitvityIndicator.startAnimating()
       cell.foodImage.image = #imageLiteral(resourceName: "empty")
        isInternetAvailable() { answer in
            guard answer == true else {
                cell.foodCellAcitvityIndicator.stopAnimating()
                return
            }
        }

     
        if let image = self.vendor.pictures[indexPath.row] {
            
            cell.showImage(image: image)
        } else {

       }

        return cell
        
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
    
    @IBAction func getDirectionsPushed(_ sender: Any) {
       getDirections(lat: vendor.lat, long: vendor.long, vc: self)
    }
    
}





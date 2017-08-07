//
//  FoodTruckInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/21/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

class FoodTruckInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let vendor = testVendor
  
    
    @IBOutlet weak var truckImage: UIImageView!
    @IBOutlet weak var truckName: UILabel!
    @IBOutlet weak var truckDescription: UILabel!
    @IBOutlet weak var foodImageCollection: UICollectionView!
    @IBOutlet weak var foodImageCollectionFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodImageCollection.delegate = self
       foodImageCollection.dataSource = self
        setupLabels()
        setupTruckImage()
        layoutCells()
    }
    
    func setupTruckImage() {
        truckImage.image = self.vendor.truckImage
    }
    
    func setupLabels() {
        truckName.text = vendor.name
        truckDescription.text = vendor.description
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return (self.vendor.pictures.count) // maxNumberOfFoodImages
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodImageCollectionViewCell", for: indexPath) as! FoodImageCollectionViewCell
        let image = self.vendor.pictures[(indexPath as NSIndexPath).row]
        cell.foodImage.image = image
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
}





//
//  FoodImageCollectionViewCell.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/31/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

class FoodImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodCellAcitvityIndicator: UIActivityIndicatorView!
    
    func showImage(image : UIImage ) {
        self.foodCellAcitvityIndicator.hidesWhenStopped = true
        if image != #imageLiteral(resourceName: "empty") {
            DispatchQueue.main.async {

                self.foodImage.image = image
                self.foodCellAcitvityIndicator.stopAnimating()
            }
        }
    }
}

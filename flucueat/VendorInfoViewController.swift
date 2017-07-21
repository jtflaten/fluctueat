//
//  VendorInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/18/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

class VendorInfoViewController: UIViewController {
    
    
    @IBOutlet weak var foodTruckImage: UIImageView!
    @IBOutlet weak var truckName: UITextField!
    @IBOutlet weak var truckDescription: UITextField!
    @IBOutlet weak var foodImageCollection: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
   // var foodTruck: Vendor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setuptextFields()
        setupTruckImage()
        
    }
    
    func setupTruckImage() {
        foodTruckImage.image = #imageLiteral(resourceName: "jakes_truck")
        foodTruckImage.backgroundColor = .gray
    }
    
    func setuptextFields(){
        truckName.text = "Enter The NAME of Your truck here"
        truckDescription.text = "enter a short description of your food here"
    }
    
    
}

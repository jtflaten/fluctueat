//
//  FoodTruckInfoViewController.swift
//  fluctueat
//
//  Created by Jake Flaten on 7/21/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit
import Firebase

class FoodTruckInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
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
        configureBackground()
        setupLabels()
        setupTruckImage()
        setupFoodImage()
        layoutCells()
     //   navigationController!.delegate = self
        setupNavBarItems()
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
        truckImage.layer.cornerRadius = 3.0
        truckImage.clipsToBounds = true
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
       getDirections()
    }
    
    func configureBackground() {
        
//        let backgroundGradient = CAGradientLayer()
//        let colorTop = UIColor(red:0.90, green:0.76, blue:0.13, alpha:1.0).cgColor
      let colorBottom = UIColor(red:0.82, green:0.01, blue:0.11, alpha: 1.0).cgColor
//
//        backgroundGradient.colors = [colorTop, colorBottom]
//        backgroundGradient.locations = [0.0, 1.0]
//        backgroundGradient.frame = view.frame
//        view.layer.insertSublayer(backgroundGradient, at: 0)
        view.layer.backgroundColor = colorBottom
    }
    
    func getDirections() {
        let coordinates = "\(vendor.lat),\(vendor.long)"
        let googleUrlScheme = "https://www.google.com/maps/search/?api=1&query=\(coordinates)"
        let app = UIApplication.shared
        if let toOpen = URL(string: googleUrlScheme) {
            guard app.canOpenURL(toOpen) else {
                self.alertView(title: "Something's gone wrong", message: "We can't open up a Maps App", dismissAction: "Ok")
                return
            }
            app.open(toOpen, options: [:], completionHandler: nil)
        }
        print(googleUrlScheme)
    }
    
    func setupNavBarItems() {
//        let callButton = UIButton(type: .system)
//        callButton.setImage(#imageLiteral(resourceName: "call").withRenderingMode(.alwaysOriginal), for: .normal)
//        callButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let mapButton = UIButton(type: .system)
        mapButton.setImage(#imageLiteral(resourceName: "map"), for: .normal)
        mapButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        mapButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        
//        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: callButton), UIBarButtonItem(customView: mapButton)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mapButton)
    }
}





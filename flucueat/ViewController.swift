//
//  ViewController.swift
//  flucueat
//
//  Created by Jake Flaten on 7/6/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let twoFingerSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(HomeMapViewController.swipeToAuthPage))
        twoFingerSwipeGestureRecognizer.numberOfTouchesRequired = 2
       // twoFingerSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up
        
        self.view.addGestureRecognizer(twoFingerSwipeGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func swipeToAuthPage(gestureRecognizer: UISwipeGestureRecognizer){
        let authController = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        print("swiped2")
        self.present(authController, animated: true)
    }

}


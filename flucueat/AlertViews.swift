//
//  AlertViews.swift
//  fluctueat
//
//  Created by Jake Flaten on 8/7/17.
//  Copyright © 2017 Break List. All rights reserved.
//

import UIKit

extension UIViewController {
 
    
    func showEmptyTextAlert () {
         let quickDismiss = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        let alert = UIAlertController(title: "Hold On", message: "please make sure you provide a truck name AND a food description", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(quickDismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertView(title: String, message: String, dismissAction: String) {
        let dismiss = UIAlertAction(title: dismissAction, style: UIAlertActionStyle.default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertViewWithPopToRoot(title: String, message: String, dismissAction: String) {
        let dismiss = UIAlertAction(title: dismissAction, style: UIAlertActionStyle.default) { (alertAction) in
            self.navigationController?.popToRootViewController(animated: true)
           return
        }
     
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(dismiss)
            

        self.present(alert, animated: true, completion:  nil)
    }
    
    
    
    
}

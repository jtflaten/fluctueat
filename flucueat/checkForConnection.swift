//
//  checkForConnection.swift
//  fluctueat
//
//  Created by Jake Flaten on 9/14/17.
//  Copyright © 2017 Break List. All rights reserved.
//


import Foundation
import SystemConfiguration

// the majority of this code was adapted from stackoverflow, to make sure that the phone is connectected to a network, and that network is connected to the internet. the SO answer is at https://stackoverflow.com/questions/39558868/check-internet-connection-ios-10

func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    
    return (isReachable && !needsConnection)
    
}

func isInternetAvailable(completionHandler: @escaping (Bool) -> Void) {
    
   
    guard isConnectedToNetwork() else {
        completionHandler(false)
        return
    }
    
    let webAddress = "https://www.google.com" // Default Web Site

    
    guard let url = URL(string: webAddress) else {
        completionHandler(false)
        print("could not create url from: \(webAddress)")
        return
    }
    
    let urlRequest = URLRequest(url: url)
    let session = URLSession.shared
    let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
        if error != nil || response == nil {
            completionHandler(false)
        } else {
            completionHandler(true)
        }
    })
    
    task.resume()
}

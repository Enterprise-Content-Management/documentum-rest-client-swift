//
//  ActivityIndicatorHelper.swift
//  RestClient
//
//  Created by Song, Michyo on 6/20/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ActivityIndicatorHelper {
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 1000, 1000))
    
    func addActivityIndicator(parentView: UIView) {
        activityIndicator.activityIndicatorViewStyle = .Gray
        activityIndicator.center = parentView.center
        activityIndicator.hidesWhenStopped = true
        parentView.addSubview(activityIndicator)
    }
    
    // MARK: - Activity indicator handling
    func startActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.backgroundColor = UIColor.clearColor()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
}

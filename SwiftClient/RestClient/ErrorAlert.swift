//
//  ErrorAlert.swift
//  RestClient
//
//  Created by Song, Michyo on 6/27/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ErrorAlert {
    
    static func show(msg: String, controller: UIViewController) {
        let alertController = UIAlertController(
            title: "Error Alert",
            message: msg,
            preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
            title: "Dismiss",
            style: .Default) { UIAlertAction in
                dismissThisViewController(controller)
            }
        )
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func dismissThisViewController(controller: UIViewController) {
        var navi: UINavigationController = controller.navigationController!
        if navi.viewControllers.count == 1 {
            if navi.navigationController != nil {
                navi = navi.navigationController!
            }
        }
        navi.setNavigationBarHidden(false, animated: true)
        navi.popViewControllerAnimated(true)
    }
    
}

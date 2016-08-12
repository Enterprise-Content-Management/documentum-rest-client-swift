//
//  UIUtil.swift
//  RestClient
//
//  Created by Song, Michyo on 8/12/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class UIUtil {
    
    static func getViewController(name: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewControllerWithIdentifier(name)
        return viewController
    }
    
    static func getTopController() -> UIViewController? {
        var rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        while (rootViewController is SWRevealViewController || rootViewController is UINavigationController) {
            if rootViewController is SWRevealViewController {
                let swRevealVC = rootViewController as! SWRevealViewController
                rootViewController = swRevealVC.frontViewController
            } else {
                let naviVC = rootViewController as! UINavigationController
                rootViewController = naviVC.topViewController
            }
        }
        return rootViewController
    }
}

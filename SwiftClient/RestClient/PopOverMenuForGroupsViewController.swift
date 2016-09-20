//
//  PopOverMenuForMembersViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/2/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class PopOverMenuForMembersViewController: UITableViewController {
    
    var dismissSelf: Bool = false
    var chosedGroup: Group!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if dismissSelf {
            dismissSelf = false
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        dismissSelf = true
        if segue.identifier == "CreateUser" {
            // Just segue to it would be ok
        } else if segue.identifier == "ShowUsers" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let nextViewController = navigationController.topViewController as! MultiMemberViewController
            nextViewController.parentGroup = chosedGroup
            nextViewController.isGroups = false
        } else if segue.identifier == "CreateGroup" {
            // Just segue to it would be ok
        } else if segue.identifier == "ShowGroups" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let nextViewController = navigationController.topViewController as! MultiMemberViewController
            nextViewController.parentGroup = chosedGroup
            nextViewController.isGroups = true
        }
    }
}

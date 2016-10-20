//
//  PopOverMenuForMembersViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/2/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class PopOverMenuForMembersViewController: AbstractPopOverMenuController {
    var chosedGroup: Group!
    var disableCreateUser: Bool = false
    var disableCreateGroup: Bool = false

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if chosedGroup == nil {
            if disableCreateUser {
                unshowCreateUser()
            }
            if disableCreateGroup {
                unshowCreateGroup()
            }
        }
    }
    
    private func unshowCreateUser() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let button = cell?.subviews[0].subviews[0] as! UIButton
        button.enabled = false
        button.selected = false
    }
    
    private func unshowCreateGroup() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        let button = cell?.subviews[0].subviews[0] as! UIButton
        button.enabled = false
        button.selected = false
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

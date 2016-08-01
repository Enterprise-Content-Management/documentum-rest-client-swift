//
//  SideMenuViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/27/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {
    var repo: RestObject!
    
    let logoutIndex = NSIndexPath(forRow: 1, inSection: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.preferredContentSize = CGSize(width: 250, height: 600)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        
        let revealVC = self.revealViewController() as SWRevealViewController
        revealVC.setFrontViewPosition(FrontViewPosition.Left, animated: true)
        
        if indexPath == logoutIndex {
            revealVC.navigationController?.setNavigationBarHidden(false, animated: true)
            revealVC.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "ShowProfile" {
            let naviVC = segue.destinationViewController as! UINavigationController
            let profileViewController = naviVC.topViewController as! ProfileViewController
            profileViewController.userUrl = repo.getLink(LinkRel.currentUser.rawValue)
        }
    }
    
}

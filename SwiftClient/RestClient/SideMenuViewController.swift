//
//  SideMenuViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/27/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {
    
    var currentUser: User!
    
    let logoutIndex = NSIndexPath(forRow: 1, inSection: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.preferredContentSize = CGSize(width: 250, height: 600)
    }
    
    // MARK: - Admin controll
    
    private func showGroupControll() -> Bool {
        if currentUser != nil {
            let userPrivileges = currentUser.getProperty("user_privileges")!
            return Int(userPrivileges)! >= 8
        } else {
            return false
        }
    }
    
    private func hideGroupSection(section: Int) -> Bool {
        return !showGroupControll() && section == 2
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if hideGroupSection(section) {
            return 0.0
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if hideGroupSection(section) {
            return nil
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideGroupSection(section) {
            return 0;
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    // MARK: - Table view control
    
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
            profileViewController.userUrl = Context.repo.getLink(LinkRel.currentUser.rawValue)
        } else if segue.identifier == "ShowGroups" {
            let naviCV = segue.destinationViewController as! UINavigationController
            let groupsViewController = naviCV.topViewController as! MembersViewController
            groupsViewController.groupsUrl = Context.repo.getLink(LinkRel.groups.rawValue)
            groupsViewController.navigationItem.title = "Groups Management"
        } else if segue.identifier == "ShowUsers" {
            let naviCV = segue.destinationViewController as! UINavigationController
            let usersViewController = naviCV.topViewController as! MembersViewController
            usersViewController.groupsUrl = Context.repo.getLink(LinkRel.users.rawValue)
            usersViewController.navigationItem.title = "Users Management"
        }
    }
}

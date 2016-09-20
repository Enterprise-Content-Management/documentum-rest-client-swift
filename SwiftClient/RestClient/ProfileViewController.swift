//
//  ProfileViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    var userUrl: String!
    var currentUser: User!
    var aiHelper = ActivityIndicatorHelper()
    
    @IBOutlet var okButon: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aiHelper.addActivityIndicator(self.view)
        getCurrentUser()
    }
    
    private func getCurrentUser() {
        if currentUser != nil {
            userUrl = currentUser.getLink(LinkRel.selfRel.rawValue)
            tableView.reloadData()
            setTableView(currentUser)
        } else {
            aiHelper.startActivityIndicator()
            RestService.getUser(userUrl) { object, error in
                if let user = object {
                    self.currentUser = user
                    print("Current user is \(user.getName()).")
                    
                    self.view?.bringSubviewToFront(self.tableView)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        self.setTableView(user)
                        self.aiHelper.stopActivityIndicator()
                    })
                }
            }
        }
    }
    
    private func setTableView(user: User) {
        self.navigationItem.title = user.getName()
        
        // Set auto layout for cell
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Tableview control
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic"
        case 1:
            return "Properties"
        case 2:
            return "Links"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentUser == nil {
            return 0
        }
        switch section {
        case 0:
            return currentUser.basic.count
        case 1:
            return currentUser.properties.count
        case 2:
            return currentUser.links.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "InfoItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InfoItemTableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        let dic: Dictionary<String, String>
        
        switch section {
        case 0:
            dic = currentUser.basic
        case 1:
            dic = currentUser.properties
            cell.infoNameLabel.font = cell.infoNameLabel.font.fontWithSize(14)
        case 2:
            dic = currentUser.links
            cell.infoNameLabel.font = cell.infoNameLabel.font.fontWithSize(14)
            cell.infoValueLabel.font = cell.infoValueLabel.font?.fontWithSize(12)
        default:
            dic = [:]
        }
        
        let index = dic.startIndex.advancedBy(row)
        let key = dic.keys[index]
        cell.infoNameLabel.text = key
        cell.infoValueLabel.text = dic[key]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Navigation
    @IBAction func onClickOK(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

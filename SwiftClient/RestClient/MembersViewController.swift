//
//  MembersViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 8/26/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class MembersViewController: ListViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet var footView: UILabel!
    
    // Only used by first time into Groups
    var groupsUrl: String!
    
    var parentGroup: RestObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigatorName()
        setFootViewWithAi(footView)
        setSearchBarOffset()
        
        // Enable swipe right to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.setHidesBackButton(true, animated: true)
        
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable swipe right to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func loadData(page: NSInteger = 1) {
        super.loadData()
        
        let ai: ActivityIndicatorHelper
        if page == 1 {
            ai = aiHelper
        } else {
            ai = footAiHelper
        }
        ai.startActivityIndicator()
        
        let memberUsersUrl: String
        if let group = parentGroup {
            groupsUrl = group.getLink(LinkRel.groups.rawValue)!
            memberUsersUrl = group.getLink(LinkRel.users.rawValue)!
        } else {
            memberUsersUrl = ""
        }
        
        let groupsService = GroupCollectionService()
        groupsService.setUrl(groupsUrl)
        groupsService.getEntries(page, thisViewController: self) { objects, isLastPage in
            self.isLastPage = isLastPage
            for object in objects {
                self.objects.append(object)
            }
            // set for ui
            self.view?.bringSubviewToFront(self.tableView)
            ai.stopActivityIndicator()
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                self.tableView.reloadData()
            })
        }
        
        if !memberUsersUrl.isEmpty {
            groupsService.setUrl(memberUsersUrl)
            groupsService.getEntries(page, thisViewController: self) { objects, isLastPage in
                self.isLastPage = isLastPage
                for object in objects {
                    self.objects.append(object)
                }
                // set for ui
                self.view?.bringSubviewToFront(self.tableView)
                ai.stopActivityIndicator()
                
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func setNavigatorName() {
        if let item = parentGroup {
            navigationItem.title = item.getName()
        }
    }
    
    // MARK: - Search handling
    override func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredObjects = objects.filter { object in
            return object.getName().lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive() {
            return filteredObjects.count
        }
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "GroupItemCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemberTableViewCell

        let object: RestObject
        if self.isSearchActive() {
            object = self.filteredObjects[indexPath.row]
        } else {
            object = self.objects[indexPath.row]
        }
        
        if object is Group {
            cell.accessoryType = .DisclosureIndicator
            
        } else if object is User {
            cell.accessoryType = .None
        }
        cell.initCell(object.getType(), name: object.getName())
        
        return cell
    }
    
    // Directly show users instead of inner groups
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let restObject: RestObject
        if self.searchController.active {
            restObject = self.filteredObjects[indexPath.row]
        } else {
            restObject = self.objects[indexPath.row]
        }
        
        if restObject.getLink(LinkRel.users.rawValue) != nil {
            let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MembersViewController") as! MembersViewController
            nextViewController.parentGroup = restObject
            navigationController!.pushViewController(nextViewController, animated: true)
        } else {
            let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            nextViewController.currentUser = restObject as! User
            navigationController!.pushViewController(nextViewController, animated: true)
        }
    }
    
    override func doDelete(indexPath: NSIndexPath) {
        if parentGroup == nil {
            super.doDelete(indexPath)
        } else {
            aiHelper.startActivityIndicator()
            let object = objects[indexPath.row] as RestObject
            let objectFullName = "\(objects[indexPath.row].getType()) \(objects[indexPath.row].getName())"
            
            if object.getLink(LinkRel.delete.rawValue) != nil {
                let removeLink = object.getLink(LinkRel.removeMember.rawValue)!
                RestService.deleteWithAuth(removeLink) { result, error in
                    if result != nil {
                        print("Successfully remove \(objectFullName) from group \(self.parentGroup!.getName()).")
                        self.aiHelper.stopActivityIndicator()
                    }
                }
            }
            
            print("Delete \(objectFullName) from list.")
            objects.removeAtIndex(indexPath.row)
            setFootViewText(objects.count)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func showAlert(indexPath: NSIndexPath, type: String, name: String, message: String) {
        super.showAlert(indexPath, type: type, name: name,
                        message: "Are you sure to remove this \(type.lowercaseString) named \(name) from GROUP \(parentGroup!.getName())")
    }
    
    // - MARK: Button actions
    @IBAction func onClickClose(sender: UIBarButtonItem) {
        let naviVC = self.navigationController! as UINavigationController
        naviVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickAdd(sender: UIBarButtonItem) {
        popUpMenu(sender)
    }
    
    // - MARK: Popover control
    
    func popUpMenu(sender: UIBarButtonItem) {
        let menuView: PopOverMenuForMembersViewController
        if parentGroup != nil {
            menuView = UIUtil.getViewController("MembersPopOverMenu") as! PopOverMenuForMembersViewController
            menuView.chosedGroup = parentGroup as! Group
            menuView.preferredContentSize = CGSizeMake(160, 85)
        } else {
            menuView = UIUtil.getViewController("GroupsPopOverMenu") as! PopOverMenuForMembersViewController
            menuView.preferredContentSize = CGSizeMake(150, 85)
        }
        menuView.modalPresentationStyle = .Popover
        
        let popOverPresentationController = menuView.popoverPresentationController!
        popOverPresentationController.barButtonItem = sender
        popOverPresentationController.permittedArrowDirections = .Any
        popOverPresentationController.delegate = self
        
        presentViewController(menuView, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let buttonDone = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(MembersViewController.dismissPopOver))
        navigationController.topViewController!.navigationItem.rightBarButtonItem = buttonDone
        return navigationController
    }
    
    func dismissPopOver() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

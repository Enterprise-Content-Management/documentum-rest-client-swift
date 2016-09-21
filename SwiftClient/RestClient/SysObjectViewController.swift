//
//  SysObjectViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 4/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SysObjectViewController: ListViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var footView: UILabel!
    
    var parentObject: RestObject?
    var thisUrl: String?
    
    var addableTypes = [
        RestObjectType.cabinet.rawValue,
        RestObjectType.folder.rawValue,
        RestObjectType.document.rawValue
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigatorName()
        setFootViewWithAi(footView)
        
        self.loadData()
        
        // Set side menu toggle
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        // Enable swipe right to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable swipe right to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setNavigatorName() {
        if let item = parentObject {
            navigationItem.title = item.getName()
        }
    }
    
    // MARK: Gesture control
    
    // Swipe to right and then go back to last page.
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count <= 1 {
            return false
        }
        return true
    }
    
    // MARK: Table view control
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let restObject: RestObject
        if self.searchController.active {
            restObject = self.filteredObjects[indexPath.row]
        } else {
            restObject = self.objects[indexPath.row]
        }
        
        if restObject.getLink(LinkRel.objects.rawValue) != nil {
            let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SysObjectCollectionView") as! SysObjectViewController
            nextViewController.parentObject = restObject
            self.navigationController!.pushViewController(nextViewController, animated: true)
        } else {
            let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InfoView") as! InfoViewController
            nextViewController.object = restObject
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
    }
    
    // MARK: Rest service control
    override func loadData(page: NSInteger = 1) {
        super.loadData()
        
        let ai: ActivityIndicatorHelper
        if page == 1 {
            ai = aiHelper
        } else {
            ai = footAiHelper
        }
        ai.startActivityIndicator()
        
        let nextUrl: String
        if parentObject!.getType() == RestObjectType.repository.rawValue {
            nextUrl = parentObject!.getLink(LinkRel.cabinets.rawValue)!
        } else {
            nextUrl = parentObject!.getLink(LinkRel.objects.rawValue)!
        }
        let sysObjectService = SysObjectCollectionService(parentObject: parentObject!, url: nextUrl)
        self.thisUrl = nextUrl
        sysObjectService.getEntries(page, thisViewController: self) { sysObjects, isLastPage in
            self.isLastPage = isLastPage
            for sysObject in sysObjects {
                self.objects.append(sysObject)
                let photo = self.getPhotoByType(sysObject.getType())
                let item = Item(url: sysObject.getId(), fileType: sysObject.getType(), fileName: sysObject.getName(), photo: photo)
                self.items.append(item)
            }
            // set for ui
            self.view?.bringSubviewToFront(self.tableView)
            ai.stopActivityIndicator()
            
            // refresh list view to show all items
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func getPhotoByType(type: String) -> UIImage {
        switch type {
            case RestObjectType.document.rawValue:
                return UIImage(named: "DocumentImage")!
            case RestObjectType.folder.rawValue:
                return UIImage(named: "FolderImage")!
            case RestObjectType.cabinet.rawValue:
                return UIImage(named: "CabinetImage")!
            default:
                return UIImage(named: "SystemFileImage")!
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "AddObject" {
            var types: [String]
            if parentObject!.getType() == RestObjectType.repository.rawValue {
                types = [self.addableTypes[0]]
            } else {
                types = addableTypes
                types.removeAtIndex(0)
            }
            let addObjectViewController = segue.destinationViewController as! AddObjectViewController
            addObjectViewController.typePickData = types
            addObjectViewController.postUrl = thisUrl!
        }
    }
    
    // MARK: - Button control
    @IBAction func onClickMore(sender: UIBarButtonItem) {
        popUpMenu(sender)
    }
    
    // MARK: Shift control & Action sheet
    // Handle shift operation on single item
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let type = objects[indexPath.row].getType()
        if type == RestObjectType.sysObject.rawValue ||
            (type == RestObjectType.cabinet.rawValue && Context.clickBoard == nil) {
            return super.tableView(tableView, editActionsForRowAtIndexPath: indexPath)
        }
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { action, indexPath in
            self.showAlert(indexPath, type: self.objects[indexPath.row].getType(), name: self.objects[indexPath.row].getName())
            tableView.setEditing(false, animated: false)
        }
        let moreAction = UITableViewRowAction(style: .Default, title: "More") { action, indexPath in
            self.showMoreActionSheet(indexPath)
            tableView.setEditing(false, animated: false)
        }
        moreAction.backgroundColor = UIColor.lightGrayColor()
        
        deleteAction.backgroundColor = UIColor.redColor()
        return [deleteAction, moreAction]
    }
    
    internal func showMoreActionSheet(indexPath: NSIndexPath) {
        let object = objects[indexPath.row]
        let actionSheet = UIAlertController(
            title: "More...",
            message: "What do you want to do with this object?",
            preferredStyle:  .ActionSheet
        )
        if object.getType() != RestObjectType.cabinet.rawValue {
            let addToClickboardAction = UIAlertAction(title: "Add To Clickboard", style: .Default) { (action: UIAlertAction!) in
                self.addToClickboard(object)
            }
            actionSheet.addAction(addToClickboardAction)
        }
        
        if object.getType() != RestObjectType.document.rawValue && Context.clickBoard != nil {
            let copyHere = UIAlertAction(title: "Copy Here", style: .Default) { (action: UIAlertAction!) in
                self.copyHere(object)
            }
            actionSheet.addAction(copyHere)
            let moveHere = UIAlertAction(title: "Move Here", style: .Default) { (action: UIAlertAction!) in
                self.moveHere(object)
            }
            actionSheet.addAction(moveHere)
            let linkHere = UIAlertAction(title: "Link Here", style: .Default) { (action: UIAlertAction!) in
                self.linkHere(object)
            }
            actionSheet.addAction(linkHere)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func addToClickboard(object: RestObject) {
        Context.clickBoard = object
        print("Add \(object.getNameWithType()) to clickboard.")
    }
    
    private func copyHere(object: RestObject) {
        print("Copy \(Context.clickBoard.getNameWithType()) to \(object.getNameWithType())")
        MiscService.copyTo(object, thisController: self) {
            self.refreshData()
        }
    }
    
    private func moveHere(object: RestObject) {
        print("Move \(Context.clickBoard.getNameWithType()) to \(object.getNameWithType())")
        
        MiscService.moveTo(object, thisController: self) {
            self.refreshData()
        }
    }
    
    private func linkHere(object: RestObject) {
        print("Link \(Context.clickBoard.getNameWithType()) to \(object.getNameWithType())")
        
        MiscService.linkTo(object, thisController: self) {
            self.refreshData()
        }
    }
    
    // - MARK: Popover control
    
    func popUpMenu(sender: UIBarButtonItem) {
        let menuView = UIUtil.getViewController("SysObjectMoreMenu") as! PopOverMenuForSysObjectController
        menuView.preferredContentSize = CGSizeMake(120, 44)
        menuView.modalPresentationStyle = .Popover
        menuView.parentObject = parentObject!
        
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
        let buttonDone = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(SysObjectViewController.dismissPopOver))
        navigationController.topViewController!.navigationItem.rightBarButtonItem = buttonDone
        return navigationController
    }
    
    func dismissPopOver() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

//
//  SysObjectViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 4/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SysObjectViewController: ListViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var footView: UILabel!
    
    var parentObject: RestObject?
    var thisUrl: String?
    var formerPath: String = ""
    var isActive: Bool = false
    
    var addableTypes = [
        RestObjectType.cabinet.rawValue,
        RestObjectType.folder.rawValue,
        RestObjectType.document.rawValue
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFootViewWithAi(footView)
        setNaviLabel()
        setSearchBar()
        
        loadData()
        
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
    
    func setNaviLabel() {
        if let naviBar = navigationController?.navigationBar {
            let frame = CGRect(x: 0, y: 0, width: naviBar.frame.width, height: naviBar.frame.height)
            let label = UILabel(frame: frame)
            label.lineBreakMode = .ByTruncatingHead
            label.textAlignment = .Center
            label.font = UIFont.boldSystemFontOfSize(18.0)
            navigationItem.titleView = label
            label.text = formerPath + "/" + (parentObject?.getName())!
            formerPath = label.text!
        }
    }
    
    func setSearchBar() {
        // Set search controller
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .None
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
            nextViewController.formerPath = formerPath
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
    
    // - MARK: Search control
    override func isSearchActive() -> Bool {
        return isActive
    }
    
    override func filterContentForSearchText(searchText: String, scope: String) {
        // do nothing to work around this function
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        filteredObjects.removeAll()
        isActive = true
        tableView.reloadData()
    }
   
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchUrl = Context.repo.getLink(LinkRel.search.rawValue)!.characters.split("{").map(String.init)[0]
        var pathPieces = formerPath.characters.split("/").map(String.init)
        pathPieces.removeFirst(1)
        var locations = pathPieces.joinWithSeparator("/")
        if !pathPieces.isEmpty {
            locations = "/" + locations
        }
        let q = searchBar.text! + "*"
        let params = ["locations": locations, "q": q, "inline": "true"] as [String: String]
        RestService.getResponseWithAuthAndParam(searchUrl, params: params) { response, error in
            if let error = error {
                ErrorAlert.show(error.message, controller: self, dismissViewController: false)
            } else if let array = response {
                for entry in array {
                    let dic = entry as! NSDictionary
                    let object = self.constructSearchResultObject(dic)
                    self.filteredObjects.append(object)
                }
                    self.tableView.reloadData()
            }
        }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isActive = false
        tableView.reloadData()
    }
    
    private func constructSearchResultObject(dic: NSDictionary) -> RestObject {
        let name = dic["title"] as! String
        let linkDic = (dic["links"] as! NSArray)[0] as! NSDictionary
        let id = linkDic["href"] as! String
        let contentDic = dic["content"] as! NSDictionary
        let propertiesDic = contentDic["properties"] as! NSDictionary
        let type = propertiesDic["r_object_type"] as! String
        let result = RestObject(id: id, name: name)
        result.setTypeWithDmType(type)
        return result
    }
}

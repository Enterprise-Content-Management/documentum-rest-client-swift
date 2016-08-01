//
//  SysObjectViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 4/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SysObjectViewController: ListViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var footView: UILabel!
    
    var parentObject: RestObject?
    var thisUrl: String?
    
    var addableTypes = ["dm_cabinet", "dm_folder", "dm_document"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigatorName()
        setFootViewWithAi(footView)
        
        self.loadData()
        print("this url: \(thisUrl!)")
        
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

}

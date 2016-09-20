//
//  ListViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 3/31/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, UISearchResultsUpdating {
    var items = [Item]()
    var objects = [RestObject]()
    
    // Properties for search bar
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItems = [Item]()
    var filteredObjects = [RestObject]()
    
    // Properties for activity indicator
    var aiHelper = ActivityIndicatorHelper()
    var footAiHelper = ActivityIndicatorHelper()
    
    var needReloadData: Bool = false
    var page = 1
    var isLastPage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSearchBar()
        initRefreshControl()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        initActivityIndicators()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needReloadData {
            self.reloadData()
        }
        self.setSearchBarOffset()
    }
    
    // MARK: - Utility
    
    // Must be override by child controller
    internal func loadData(page: NSInteger = 1) {
        // load List View data.
    }
    
    internal func reloadData() {
        page = 1
        clearAll()
        loadData()
        self.tableView.reloadData()
    }
    
    internal func loadNextPageData() {
        page = page + 1
        loadData(page)
    }
    
    // Clear all stored data
    private func clearAll() {
        self.items.removeAll()
        self.objects.removeAll()
        self.filteredItems.removeAll()
        self.filteredObjects.removeAll()
    }
    
    // MARK: - UI 
    
    // Set offset for tableView so that searchBar would not show on screen unless pull down list.
    internal func setSearchBarOffset() {
        if tableView.contentOffset == CGPoint(x: 0, y: 0) {
            let searchBarHeight = tableView.tableHeaderView!.frame.size.height
            tableView.contentOffset = CGPointMake(0, searchBarHeight)
        }
    }
    
    internal func setFootViewWithAi(footView: UIView) {
        footAiHelper.addActivityIndicator(footView)
        tableView.tableFooterView = footView
    }
    
    private func initActivityIndicators() {
        aiHelper.addActivityIndicator(view)
    }
    
    private func initSearchBar() {
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ListViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    // MARK: - Search handling
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
    
    internal func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredItems = items.filter { item in
            return item.itemName.lowercaseString.containsString(searchText.lowercaseString)
        }
        self.filteredObjects = objects.filter { object in
            return object.getName().lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    internal func isSearchActive() -> Bool {
        return searchController.active && searchController.searchBar.text != ""
    }
    
    // MARK: - Table view data source
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive() {
            return filteredItems.count
        }
        return items.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ItemTableViewCell
        
        let item: Item
        if self.isSearchActive() {
            item = self.filteredItems[indexPath.row]
        } else {
            item = self.items[indexPath.row]
        }
        
        // Set different view for disclosurable item and the opposite.
        let buttons = cell.contentView.subviews.filter{ view in
            return view is UIButton
        }
        let infoButton = buttons[0]
        if item.itemType == RestObjectType.cabinet.rawValue
            || item.itemType == RestObjectType.folder.rawValue
            || item.itemType == RestObjectType.repository.rawValue {
            cell.accessoryType = .DisclosureIndicator
            infoButton.hidden = false
        } else {
            cell.accessoryType = .None
            infoButton.hidden = true
        }
        
        cell.fileNameLabel.text = item.itemName
        cell.fileTypeLabel.text = item.itemType
        cell.thumbnailPhotoImageView.image = item.photo
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastRow = objects.count - 1
        if indexPath.row == lastRow {
            if !isLastPage {
                if indexPath.row == lastRow {
                    self.loadNextPageData()
                }
            } else {
                setFootViewText(objects.count)
            }
        }
    }
    
    internal func setFootViewText(num: NSInteger) {
        let label = tableView.tableFooterView! as! UILabel
        label.text = "- \(num) objects in total -"
    }

    // Handle shift operation on single item
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { action, indexPath in
            self.showAlert(indexPath, type: self.objects[indexPath.row].getType(), name: self.objects[indexPath.row].getName())
            tableView.setEditing(false, animated: false)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        return [deleteAction]
    }
    
    internal func showAlert(indexPath: NSIndexPath, type: String, name: String, message: String = "") {
        let showingMessage: String
        if message.isEmpty {
            showingMessage = "Are you sure to delete this \(type.lowercaseString) named \(name)"
        } else {
            showingMessage = message
        }
        let alertController = UIAlertController(
            title: "Delete Warning",
            message: showingMessage,
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .Cancel) { (action: UIAlertAction!) in
            self.cancelDelete(indexPath)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) in
            self.doDelete(indexPath)
        }
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    internal func doDelete(indexPath: NSIndexPath) {
        aiHelper.startActivityIndicator()
        let object = objects[indexPath.row] as RestObject
        let objectFullName = "\(objects[indexPath.row].getType()) \(objects[indexPath.row].getName())"
        
        if object.getLink(LinkRel.delete.rawValue) != nil {
            let deletLink = object.getLink(LinkRel.delete.rawValue)!
            RestService.deleteWithAuth(deletLink) { result, error in
                if result != nil {
                    print("Successfully delete \(objectFullName) from cloud.")
                    self.aiHelper.stopActivityIndicator()
                }
            }
        }
        
        print("Delete \(objectFullName) from list.")
        if !items.isEmpty {
            items.removeAtIndex(indexPath.row)
        }
        objects.removeAtIndex(indexPath.row)
        setFootViewText(objects.count)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    private func cancelDelete(indexPath: NSIndexPath) {
        print("Cancel deletion.")
        self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
        
    }
    
    // Refresh data invoked when pull down list
    func refreshData() {
        self.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowInfo" {
            let infoViewController = segue.destinationViewController as! InfoViewController
            let infoButton = sender as! UIButton
            let view = infoButton.superview!
            if let selectedItemCell = view.superview as? ItemTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedItemCell)!
                // path this information to cabinetviewcontroller
                infoViewController.object = objects[indexPath.row]
            }
        }
    }
}

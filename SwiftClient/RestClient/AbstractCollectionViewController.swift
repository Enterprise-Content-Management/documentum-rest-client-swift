//
//  AbstractCollectionViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 3/31/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AbstractCollectionViewController: UITableViewController, UISearchResultsUpdating {
    var objects = [RestObject]()
    var filteredObjects = [RestObject]()
    
    // Properties for search bar
    let searchController = UISearchController(searchResultsController: nil)
    
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
        if let footView = tableView.tableFooterView as? UILabel {
            footView.text = ""
        }
        clearAll()
        loadData()
        self.tableView.reloadData()
    }
    
    internal func loadNextPageData() {
        page = page + 1
        loadData(page)
    }
    
    // Clear all stored data
    internal func clearAll() {
        objects.removeAll()
        filteredObjects.removeAll()
    }
    
    // MARK: - UI 
    
    // Set offset for tableView so that searchBar would not show on screen unless pull down list.
    internal func setSearchBarOffset() {
        if let searchBar = tableView.tableHeaderView {
            if tableView.contentOffset == CGPoint(x: 0, y: 0) {
                let searchBarHeight = searchBar.frame.size.height
                tableView.contentOffset = CGPointMake(0, searchBarHeight)
            }
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
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    internal func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AbstractCollectionViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
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
            return filteredObjects.count
        }
        return objects.count
    }
    
    internal func getSelectedObject(indexPath: NSIndexPath) -> RestObject {
        let object: RestObject
        if self.isSearchActive() {
            object = self.filteredObjects[indexPath.row]
        } else {
            object = self.objects[indexPath.row]
        }
        return object
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ItemTableViewCell
        
        let object = getSelectedObject(indexPath)
        cell.initCell(object)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let restObjects: [RestObject]
        if isSearchActive() {
            restObjects = filteredObjects
        } else {
            restObjects = objects
        }
        let lastRow = restObjects.count - 1
        if indexPath.row == lastRow {
            if !isLastPage {
                if indexPath.row == lastRow {
                    self.loadNextPageData()
                }
            } else {
                setFootViewText(restObjects.count)
            }
        }
    }
    
    internal func setFootViewText(num: NSInteger) {
        if let label = tableView.tableFooterView as? UILabel {
            label.text = "- \(num) objects in total -"
        }
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
        
        if object.getLink(LinkRel.delete) != nil {
            let deletLink = object.getLink(LinkRel.delete)!
            RestService.deleteWithAuth(deletLink) { result, error in
                if result != nil {
                    printLog("Successfully delete \(objectFullName) from cloud.")
                    self.aiHelper.stopActivityIndicator()
                }
            }
        }
        
        printLog("Delete \(objectFullName) from list.")
        if !objects.isEmpty {
            objects.removeAtIndex(indexPath.row)
        }
        objects.removeAtIndex(indexPath.row)
        setFootViewText(objects.count)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    private func cancelDelete(indexPath: NSIndexPath) {
        printLog("Cancel deletion.")
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
                if isSearchActive() {
                    infoViewController.object = filteredObjects[indexPath.row]
                } else {
                    infoViewController.object = objects[indexPath.row]
                }
            }
        }
    }
    
    // MARK: - Search handling
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredObjects = objects.filter { object in
            return object.getName().lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
}

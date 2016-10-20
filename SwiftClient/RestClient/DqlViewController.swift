//
//  DqlViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/27/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class DqlViewController: AbstractCollectionViewController, UISearchBarDelegate {
    
    @IBOutlet weak var footView: UILabel!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    var isActive: Bool = false
    
    var searchUrl: String!
    var dql: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        setUI()
        
        // For now it is not available for history
        historyButton.enabled = false
        historyButton.tintColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        if needReloadData {
            reloadData()
        }
    }
    
    private func setSearchBar() {
        // Set search controller
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .None
        searchController.searchBar.placeholder = "Search with DQL..."
    }
    
    private func setUI() {
        IconHelper.setIconForBarButton(historyButton, iconName: .History)
    }
    
    override func loadData(page: NSInteger) {
        let params = [
            "dql": dql!,
            "items-per-page": String(RestService.itemsPerPage),
            "page": String(page)
            ] as [String: String]
        RestService.getResponseWithAuthAndParam(searchUrl, params: params) { response, error in
            if let error = error {
                ErrorAlert.show(error.message, controller: self, dismissViewController: false)
            } else if let array = response {
                for entry in array {
                    let dic = entry as! NSDictionary
                    let object = DqlResult(searchDic: dic)
                    self.filteredObjects.append(object)
                    self.objects.append(object)
                }
                self.isLastPage = array.count < RestService.itemsPerPage
                self.tableView.reloadData()
            }
            self.aiHelper.stopActivityIndicator()
        }
    }
    
    // MARK: - Search control
    override func isSearchActive() -> Bool {
        return isActive
    }
    
    override func filterContentForSearchText(searchText: String, scope: String) {
        // do nothing to work around this function
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        objects.removeAll()
        filteredObjects.removeAll()
        isActive = true
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let ai: ActivityIndicatorHelper
        if page == 1 {
            ai = aiHelper
        } else {
            ai = footAiHelper
        }
        ai.startActivityIndicator()

        searchUrl = Context.repo.getLink(LinkRel.dql)!.characters.split("{").map(String.init)[0]
        dql = searchBar.text
        if dql == nil || dql!.isEmpty {
            ErrorAlert.show("Please type in dql.", controller: self, dismissViewController: false)
        }

        loadData(page)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isActive = false
        footView.text = nil
    }
    
    // MARK: - Navigation
    @IBAction func onClickCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TODO: do a history.
    @IBAction func onClickHistory(sender: UIBarButtonItem) {
        ErrorAlert.show("Remain to do", controller: self, dismissViewController: false)
    }
    
    // MARK: Table view control
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ItemTableViewCell
        
        cell.canGoDeep()
        if getSelectedObject(indexPath).getLink(LinkRel.selfRel) == nil {
            cell.getInfoButton().hidden = true
        } else {
            IconHelper.setIconForButton(cell.getInfoButton(), iconName: .Search, size: 20)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let object = getSelectedObject(indexPath)
        showPropertyView(object)
    }
    
    @IBAction func onClickInfo(sender: UIButton) {
        let cell = sender.superview!.superview as! ItemTableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let object = getSelectedObject(indexPath)
        if object.getLink(LinkRel.selfRel) != nil {
            handleSelectedObject(indexPath) { object in
                if object.getLink(LinkRel.objects.rawValue) != nil {
                    self.showFolderView(object)
                } else {
                    self.showPropertyView(object)
                }
            }
        } else {
            ErrorAlert.show("Please at least include 'r_object_id' in search proepties.", controller: self, dismissViewController: false)
        }
    }
    
    private func showFolderView(object: RestObject) {
        let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SysObjectCollectionView") as! SysObjectViewController
        nextViewController.parentObject = object
        nextViewController.formerPath = "/\(object.getName())"
        nextViewController.menuButton.enabled = false
        nextViewController.menuButton.tintColor = UIColor.clearColor()
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    
    private func showPropertyView(object: RestObject) {
        let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        nextViewController.restObject = object
        nextViewController.sectionChosed = [0, 1]
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    
    internal func handleSelectedObject(indexPath: NSIndexPath, completionHandler: (RestObject) -> Void) {
        let restObject = getSelectedObject(indexPath)
        RestService.getRestObject(restObject.getLink(LinkRel.selfRel.rawValue)!) { object, error in
            if let e = error {
                ErrorAlert.show(e.message, controller: self, dismissViewController: false)
            } else if let object = object {
                completionHandler(object)
            }
        }
    }
}

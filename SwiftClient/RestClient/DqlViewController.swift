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

        searchUrl = Context.repo.getLink(LinkRel.dql.rawValue)!.characters.split("{").map(String.init)[0]
        dql = searchBar.text
        if dql == nil || dql!.isEmpty {
            ErrorAlert.show("Please type in dql.", controller: self, dismissViewController: false)
        }
        dql = addRObjectIdInDql(dql)
        
        loadData(page)
    }
    
    private func addRObjectIdInDql(dql: String) -> String {
        var characters = dql.characters.split(" ").map(String.init)
        let selectedProperties = characters[1]
        if selectedProperties == "*" {
            return dql
        }
        if !selectedProperties.containsString("r_object_id") {
            characters[1] = characters[1] + ",r_object_id"
            let newDql = characters.joinWithSeparator(" ")
            return newDql
        }
        return dql
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
    
    internal func handleSelectedObject(indexPath: NSIndexPath, completionHandler: (RestObject) -> Void) {
        let restObject: RestObject
        if isActive {
            restObject = self.filteredObjects[indexPath.row]
        } else {
            restObject = self.objects[indexPath.row]
        }
        
        RestService.getRestObject(restObject.getLink(LinkRel.selfRel.rawValue)!) { object, error in
            if let e = error {
                ErrorAlert.show(e.message, controller: self, dismissViewController: false)
            } else if let object = object {
                completionHandler(object)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        handleSelectedObject(indexPath) { object in
            if object.getLink(LinkRel.objects.rawValue) != nil {
                self.showFolderView(object)
            } else {
                self.showInfoView(object)
            }
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
    
    private func showInfoView(object: RestObject) {
        let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InfoView") as! InfoViewController
        nextViewController.object = object
        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func onClickInfo(sender: UIButton) {
        let view = sender.superview!
        if let selectedItemCell = view.superview as? ItemTableViewCell {
            let indexPath = tableView.indexPathForCell(selectedItemCell)!
            handleSelectedObject(indexPath) { object in
                self.showInfoView(object)
            }
        }
    }
}

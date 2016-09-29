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
            "inline": "true",
            "items-per-page": String(RestService.itemsPerPage),
            "page": String(page)
            ] as [String: String]
        RestService.getResponseWithAuthAndParam(searchUrl, params: params) { response, error in
            if let error = error {
                ErrorAlert.show(error.message, controller: self, dismissViewController: false)
            } else if let array = response {
                for entry in array {
                    let dic = entry as! NSDictionary
                    let object = RestObject(searchDic: dic)
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let restObject: RestObject
        if isActive {
            restObject = self.filteredObjects[indexPath.row]
        } else {
            restObject = self.objects[indexPath.row]
        }
        
        RestService.getRestObject(restObject.getId()) { object, error in
            if let e = error {
                ErrorAlert.show(e.message, controller: self, dismissViewController: false)
            } else if let object = object {
                if object.getLink(LinkRel.objects.rawValue) != nil {
                    let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SysObjectCollectionView") as! SysObjectViewController
                    nextViewController.parentObject = object
                    nextViewController.formerPath = "/\(object.getName())"
                    self.navigationController!.pushViewController(nextViewController, animated: true)
                } else {
                    let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InfoView") as! InfoViewController
                    nextViewController.object = object
                    self.navigationController!.pushViewController(nextViewController, animated: true)
                }
            }
        }
    }
}

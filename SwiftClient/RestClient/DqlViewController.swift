//
//  DqlViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/27/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class DqlViewController: ListViewController, UISearchBarDelegate {
    
    @IBOutlet weak var footView: UILabel!
    var isActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
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
        aiHelper.startActivityIndicator()
        let searchUrl = Context.repo.getLink(LinkRel.dql.rawValue)!.characters.split("{").map(String.init)[0]
        let dql = searchBar.text
        if dql == nil || dql!.isEmpty {
            ErrorAlert.show("Please type in dql.", controller: self, dismissViewController: false)
        }
        let params = ["dql": dql!, "inline": "true"] as [String: String]
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
                self.tableView.reloadData()
            }
            self.aiHelper.stopActivityIndicator()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isActive = false
        footView.text = nil
    }
    
    // MARK: - Navigation
    @IBAction func onClickCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

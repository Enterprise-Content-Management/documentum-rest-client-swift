//
//  MultiMemberViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/5/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class MultiMemberViewController: AbstractCollectionViewController {
    @IBOutlet var footView: UILabel!
    
    var parentGroup: Group!
    var isGroups: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFootViewWithAi(footView)
        setSearchBarOffset()
        loadData()
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
        let service: RestCollectionService
        let url: String
        if isGroups {
            service = GroupCollectionService()
            url = Context.repo.getLink(LinkRel.groups)!
        } else {
            service = UserCollectionService()
            url = Context.repo.getLink(LinkRel.users)!
        }
        service.setUrl(url)
        service.getEntries(page, thisViewController: self) { objects, isLastPage in
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
        let cellIdentifier = "UserItemCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let object: RestObject
        if self.isSearchActive() {
            object = self.filteredObjects[indexPath.row]
        } else {
            object = self.objects[indexPath.row]
        }
        
        cell.textLabel?.text = object.getName()
        cell.detailTextLabel!.text = object.getType()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .None
    }
    
    // MARK: - Button control

    @IBAction func onClickCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickAdd(sender: UIBarButtonItem) {
        let selectedObjects = getSelectedObjects()
        let requestBody = getBatchRequest(selectedObjects) as! Dictionary<String, AnyObject>

        aiHelper.startActivityIndicator()
        let batchesUrl = Context.repo.getLink(LinkRel.batches)!
        RestService.createWithAuth(batchesUrl, requestBody: requestBody) { dic, error in
            if error != nil {
                ErrorAlert.show(error!.message, controller: self, dismissViewController: false)
            }
            if let response = dic {
                let operations = response["operations"] as! NSArray
                for operation in operations {
                    let op = operation as! NSDictionary
                    let description = op["description"] as! String
                    let opResponse = op["response"] as! NSDictionary
                    if opResponse["status"] as! Int == 201 {
                        printLog("Successfully \(description)")
                    } else {
                        printError("Fail to \(description)")
                    }
                }
                self.navigationController?.dismissViewControllerAnimated(true) {
                    let controller = UIUtil.getTopGroupsController()!
                    controller.reloadData()
                }
            }
        }
    }
    
    private func getSelectedObjects() -> [RestObject] {
        let indice = tableView.indexPathsForSelectedRows!
        var selectedUsers: [RestObject] = []
        for index in indice {
            let object: RestObject
            if isSearchActive() {
                object = filteredObjects[index.row]
            } else {
                object = objects[index.row]
            }
            selectedUsers.append(object)
        }
        return selectedUsers
    }
    
    private func getBatchRequest(objects: [RestObject]) -> NSDictionary {
        var operations: [NSDictionary] = []
        var id = 0
        for object in objects {
            operations.append(getSingleOperation(String(id), object: object))
            id += 1
        }
        return JsonUtility.buildBatchRequest(operations)
    }
    
    private func getSingleOperation(id: String, object: RestObject) -> NSDictionary {
        let requestUrl: String
        if isGroups {
            requestUrl = parentGroup.getLink(LinkRel.groups)!
        } else {
            requestUrl = parentGroup.getLink(LinkRel.users)!
        }
        let headers = [["name": "Content-Type", "value": RestService.MIME_JSON]] as NSArray
        let objectId = object.getLink(LinkRel.selfRel)!
        let entity = "{\"href\": \"\(objectId)\"}"
        
        return JsonUtility.buildSingleBatchOperation(
            id,
            description: "Add MEMBER \(object.getName()) to GROUP \(parentGroup.getName())",
            method: "POST",
            uri: requestUrl,
            headers: headers,
            entity: entity)
    }
}

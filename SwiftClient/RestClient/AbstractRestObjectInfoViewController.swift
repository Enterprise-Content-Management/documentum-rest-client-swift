//
//  AbstractRestObjectInfoViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/28/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AbstractRestObjectInfoViewController: UITableViewController {
    var restObject: RestObject!
    var aiHelper = ActivityIndicatorHelper()
    var sectionChosed: [Int] = [0, 1, 2]
    
    private let sectionTitles = ["Basic", "Properties", "Links"]
    private let basicSectionOrder = ["id", "type", "name", "updated"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSuperParams()
        aiHelper.addActivityIndicator(self.view)
        setTableView()
        
        loadData()
    }
    
    internal func setSuperParams() {
    }
    
    internal func loadData() {
        aiHelper.startActivityIndicator()
        tableView.reloadData()
        aiHelper.stopActivityIndicator()
    }
    
    internal func setTableView() {
        self.navigationItem.title = restObject.getName()
        
        // Set auto layout for cell
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Tableview control
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionChosed.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if sectionChosed.contains(0) {
                return "Basic"
            }
        case 1:
            if sectionChosed.contains(1) {
                return "Properties"
            }
        case 2:
            if sectionChosed.contains(2) {
                return "Links"
            }
        default:
            return ""
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restObject == nil {
            return 0
        }
        switch section {
        case 0:
            return 4 //restObject.basic.count
        case 1:
            return restObject.properties.count
        case 2:
            return restObject.links.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "InfoItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InfoItemTableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        let dic: Dictionary<String, AnyObject>
        let cellStyle: InfoItemTableViewCell.InfoItemCellStyle
        
        switch section {
        case 0:
            dic = restObject.basic
            cellStyle = .Basic
        case 1:
            dic = restObject.properties
            cellStyle = .Infomation
        case 2:
            dic = restObject.links
            cellStyle = .Link
        default:
            dic = [:]
            cellStyle = .Basic
        }

        let key: String
        
        if section == 0 {
            key = basicSectionOrder[row]
        } else {
            let sortedKeys = dic.keys.sort()
            key = sortedKeys[row]
        }
        
        cell.initCell(key, value: String(dic[key]!), style: cellStyle)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Navigation
    
    func dissmissSelf() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

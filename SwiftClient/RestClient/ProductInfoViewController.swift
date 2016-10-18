//
//  ProductInfoViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/28/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductInfoViewController: UITableViewController {
    var productInfo: Dictionary<String, JSON> = [:]
    private let sortedKeys = ["product", "product_version", "major", "minor", "build_number", "revision_number"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    private func loadData() {
        RestService.getProductInfo(Context.productInfoUrl) { json, error in
            if let json = json {
                self.productInfo = json.dictionary!["properties"]!.dictionary!
                printLog("product info : \(self.productInfo)")
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.tableView.reloadData()
                })
            } else if let error = error {
                ErrorAlert.show(error.message, controller: self)
            }
        }
    }
    
    // MARK: - Table view control
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productInfo.isEmpty {
            return 0
        }
        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PropertyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InfoItemTableViewCell
    
        let key = sortedKeys[indexPath.row]
        let showKey = key.stringByReplacingOccurrencesOfString("_", withString: " ")
        cell.initCell(showKey, value: productInfo[key]!.stringValue, style: .ProductInfo)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Navigator
    
    @IBAction func onClickOK(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

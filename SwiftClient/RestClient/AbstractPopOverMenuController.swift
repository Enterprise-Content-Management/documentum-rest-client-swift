//
//  AbstractPopOverMenu.swift
//  RestClient
//
//  Created by Song, Michyo on 10/20/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AbstractPopOverMenuController: UITableViewController {
    var dismissSelf: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if dismissSelf {
            dismissSelf = false
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

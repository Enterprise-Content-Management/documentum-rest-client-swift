//
//  UpdateViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/20/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class UpdateViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet var updateValueText: UITextField!
    
    var value: String!
    
    var type: String!
    var editUrl: String!
    
    override func viewDidLoad() {
        updateValueText.text = value
    }
    
    // MARK: - Navigation

    @IBAction func onClickSave(sender: UIBarButtonItem) {
        doUpdate {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func doUpdate(handler: ()->()) {
        let attrName = self.navigationItem.title!
        let attrValue = updateValueText.text!
        
        let requestBody = JsonUtility.getUpdateRequestBodySingleAttr(type!, attrName: attrName, attrValue: attrValue)
        RestService.updateWithAuth(self.editUrl!, requestBody: requestBody){ result, error in
            if result != nil {
                print("Successfully update \(attrName) to \(attrValue).")
                handler()
            }
        }
    }
}

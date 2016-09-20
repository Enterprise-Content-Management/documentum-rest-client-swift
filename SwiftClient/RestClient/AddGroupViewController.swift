//
//  AddGroupViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/6/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AddGroupViewController: UITableViewController {
    var aiHelper = ActivityIndicatorHelper()
    
    @IBOutlet var groupNameTextField: UITextField!
    
    override func viewDidLoad() {
        aiHelper.addActivityIndicator(view)
        view.bringSubviewToFront(tableView)
    }
    
    // MARK: - Button controll
    @IBAction func onClickCancel(sender: UIBarButtonItem) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickConfirm(sender: UIBarButtonItem) {
        let groupName = UIUtil.getText(groupNameTextField)
        if !groupName.isEmpty {
            aiHelper.startActivityIndicator()
            let attrDic = constructAttrDic()
            let postUrl = Context.repo.getLink(LinkRel.groups.rawValue)!
            let requestBody = JsonUtility.getUpdateRequestBody(RestObjectType.group.rawValue, attrDic: attrDic)
            RestService.createWithAuth(postUrl, requestBody: requestBody){ result, error in
                if result != nil {
                    print("Successfully create a new GROUP \(groupName).")
                }
                if let error = error {
                    let errorMsg = error.message
                    ErrorAlert.show(errorMsg, controller: self)
                    self.aiHelper.stopActivityIndicator()
                    return
                }
            }
        }
        
    }
    
    private func constructAttrDic() -> Dictionary<String, String> {
        var attrDic: Dictionary<String, String> = [:]
        attrDic["group_name"] = UIUtil.getText(groupNameTextField)
        return attrDic
    }
}

//
//  AddUserViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/2/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AddUserViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var loginNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    @IBOutlet weak var privilegePicker: UIPickerView!
    
    var aiHelper = ActivityIndicatorHelper()
    let userPrivilegesPickerSource: [String] = [
        "None", "Create Type", "Create Cabinet", "Create Cabinet and Type", "Create Group",
        "Create Group and Type", "Create Group and Cabinet", "Create Group, Cabinet and Type",
        "System Administrator", "Super User"
    ]
    
    override func viewDidLoad() {
        privilegePicker.dataSource = self
        privilegePicker.delegate = self
        
        aiHelper.addActivityIndicator(view)
        view.bringSubviewToFront(tableView)
    }
    
    // MARK: - Navigation
    
    @IBAction func onClickConfirm(sender: UIBarButtonItem) {
        if checkInfo() {
            aiHelper.startActivityIndicator()
            let attrDic = constructAttrDic()
            let requestBody = JsonUtility.getUpdateRequestBody(RestObjectType.user.rawValue, attrDic: attrDic)
            let postUrl = Context.repo.getLink(LinkRel.users.rawValue)!
            RestService.createWithAuth(postUrl, requestBody: requestBody){ result, error in
                if result != nil {
                    let user = User(singleDic: result!)
                    print("Successfully create a new USER \(user.getName()).")
                    self.aiHelper.stopActivityIndicator()
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    UIUtil.getTopGroupsController()!.reloadData()
                } else if let error = error {
                    self.aiHelper.stopActivityIndicator()
                    let errorMsg = error.message
                    ErrorAlert.show(errorMsg, controller: self)
                    return
                }
            }
        }
    }
    
    private func checkInfo() -> Bool {
        let username = UIUtil.getText(userNameTextField)
        let loginName = UIUtil.getText(loginNameTextField)
        let password = UIUtil.getText(passwordTextField)
        let passwordConfirm = UIUtil.getText(passwordConfirmTextField)
        
        var message: String = ""
        if username.isEmpty {
            message += "User name should not be empty. \n"
        }
        if loginName.isEmpty {
            message += "Login name should not be empty. \n"
        }
        if password.isEmpty {
            message += "Password should not be empty. \n"
        } else if password != passwordConfirm {
            message += "Passwords do not match. \n"
        }
        if !message.isEmpty {
            message += "Please check again."
            ErrorAlert.show(message, controller: self, dismissViewController: false)
            return false
        } else {
            return true
        }
    }

    private func constructAttrDic() -> Dictionary<String, AnyObject> {
        var attrDic: Dictionary<String, AnyObject> = [:]
        attrDic[ObjectProperties.USER_SOURCE.rawValue] = "inline password"
        attrDic[ObjectProperties.USER_NAME.rawValue] = UIUtil.getText(userNameTextField)
        attrDic[ObjectProperties.USER_LOGIN_NAME.rawValue] = UIUtil.getText(loginNameTextField)
        attrDic[ObjectProperties.USER_PASSWORD.rawValue] = UIUtil.getText(passwordTextField)
        attrDic[ObjectProperties.USER_PRIVILEGES.rawValue] = privilegePicker.selectedRowInComponent(0)
        return attrDic
    }
    
    @IBAction func onClickCancel(sender: UIBarButtonItem) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Table view control
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Pick view control
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userPrivilegesPickerSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userPrivilegesPickerSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // none
    }

}

//
//  AddUserViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/2/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AddUserViewController: UITableViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var loginNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    
    var aiHelper = ActivityIndicatorHelper()
    
    override func viewDidLoad() {
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
                }
                if let error = error {
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

    private func constructAttrDic() -> Dictionary<String, String> {
        var attrDic: Dictionary<String, String> = [:]
        attrDic["user_source"] = "inline_password"
        attrDic["user_name"] = UIUtil.getText(userNameTextField)
        attrDic["user_login_name"] = UIUtil.getText(loginNameTextField)
        attrDic["user_password"] = UIUtil.getText(passwordTextField)
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

}

//
//  LoginViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 5/18/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var goButton: UIBarButtonItem!
    @IBOutlet var isAutoLogin: CheckBox!
    @IBOutlet var isRemember: CheckBox!
    
    let ATTR_USERNAME = "username"
    let ATTR_PASSWORD = "password"
    let ATTR_REMEMBER = "shouldremember"
    let ATTR_AUTO = "shouldautologin"
    
    var parentObject: RestObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        userNameTextField.text = DbUtil.getValueFromTable(attrName: ATTR_USERNAME)
        passwordTextField.text = DbUtil.getValueFromTable(attrName: ATTR_PASSWORD)
        
        setCheckBoxes()
        
        if isAutoLogin.isChecked {
            performSegueWithIdentifier("SuccessLogin", sender: goButton)
        }
    }
    
    private func setCheckBoxes() {
        if DbUtil.getValueFromTable(attrName: ATTR_REMEMBER)! == "true" {
            isRemember.isChecked = true
        } else {
            isRemember.isChecked = false
        }
        
        if DbUtil.getValueFromTable(attrName: ATTR_AUTO)! == "true" {
            isAutoLogin.isChecked = true
        } else {
            isAutoLogin.isChecked = false
        }
    }
    
    // MARK: - Authentication
    
    private func checkLoginCredential() -> Bool {
        let username = userNameTextField.text
        let password = passwordTextField.text
        if (username != nil && password != nil) {
            print("Login info: username=\(username!), password=\(password!)")
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SuccessLogin"{
            return checkLoginCredential()
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let shouldRemember = isRemember.isChecked.description
        let shouldAuto = isAutoLogin.isChecked.description
        DbUtil.updateValueFromTable(attrName: ATTR_REMEMBER, attrValue: shouldRemember)
        DbUtil.updateValueFromTable(attrName: ATTR_AUTO, attrValue: shouldAuto)
        if isRemember.isChecked {
            DbUtil.updateValueFromTable(attrName: ATTR_USERNAME, attrValue: userNameTextField.text!)
            DbUtil.updateValueFromTable(attrName: ATTR_PASSWORD, attrValue: passwordTextField.text!)
        }
        
        RestUriBuilder.currentLoginCredential.userName = userNameTextField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        RestUriBuilder.currentLoginCredential.password = passwordTextField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        
        if segue.identifier == "SuccessLogin" {
            self.navigationController?.navigationBarHidden = true
            
            let revealViewController = segue.destinationViewController as! SWRevealViewController
            revealViewController.setFrontViewController(FileUtil.getViewController("MainNavi"), animated: true)
            revealViewController.setRearViewController(FileUtil.getViewController("MenuView"), animated: true)
            
            let menuViewController = revealViewController.rearViewController as! SideMenuViewController
            menuViewController.repo = self.parentObject
            let naviViewController = revealViewController.frontViewController as! UINavigationController
            let cabinetViewController = naviViewController.viewControllers.first as! SysObjectViewController
            cabinetViewController.parentObject = self.parentObject
            
            print("Successfully Log into REPOSITORY \(parentObject.getName()).")
        }
    }
}
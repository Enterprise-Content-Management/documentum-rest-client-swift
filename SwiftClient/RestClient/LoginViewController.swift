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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        userNameTextField.text = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_USERNAME)
        passwordTextField.text = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_PASSWORD)
        
        setCheckBoxes()
        
        if isAutoLogin.isChecked {
            performSegueWithIdentifier("SuccessLogin", sender: goButton)
        }
    }
    
    private func setCheckBoxes() {
        if DbUtil.getValueFromTable(attrName: DbUtil.ATTR_REMEMBER)! == "true" {
            isRemember.isChecked = true
        } else {
            isRemember.isChecked = false
        }
        
        if DbUtil.getValueFromTable(attrName: DbUtil.ATTR_AUTO)! == "true" {
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
            printLog("Login info: username=\(username!), password=\(password!)")
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
        
        recordLoginPreferences()
        handleUserLoginInfo()
        
        if segue.identifier == "SuccessLogin" {
            self.navigationController?.navigationBarHidden = true
            
            let revealViewController = segue.destinationViewController as! SWRevealViewController
            revealViewController.setFrontViewController(UIUtil.getViewController("MainNavi"), animated: true)
            revealViewController.setRearViewController(UIUtil.getViewController("MenuView"), animated: true)
            
            let menuViewController = revealViewController.rearViewController as! SideMenuViewController
            let naviViewController = revealViewController.frontViewController as! UINavigationController
            let cabinetViewController = naviViewController.viewControllers.first as! SysObjectViewController
            cabinetViewController.parentObject = Context.repo

            let currentUserUrl = Context.repo.getLink(LinkRel.currentUser)!
            RestService.getUser(currentUserUrl) { object, error in
                if let user = object {
                    menuViewController.currentUser = user
                    printLog("Successfully Log into REPOSITORY \(Context.repo.getName()) as USER \(user.getName()) with priviledge \(user.getProperty("user_privileges")!).")
                }
            }
        }
    }
    
    private func recordLoginPreferences() {
        let shouldRemember = isRemember.isChecked.description
        let shouldAuto = isAutoLogin.isChecked.description
        DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_REMEMBER, attrValue: shouldRemember)
        DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_AUTO, attrValue: shouldAuto)
    }
    
    private func handleUserLoginInfo() {
        if isRemember.isChecked {
            DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_USERNAME, attrValue: userNameTextField.text!)
            DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_PASSWORD, attrValue: passwordTextField.text!)
        }
        
        RestUriBuilder.currentLoginCredential.userName = userNameTextField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        RestUriBuilder.currentLoginCredential.password = passwordTextField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
    }
}
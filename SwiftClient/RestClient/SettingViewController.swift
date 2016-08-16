//
//  SettingViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    @IBOutlet weak var rootCell: InfoItemTableViewCell!
    @IBOutlet weak var contextCell: InfoItemTableViewCell!
    @IBOutlet var isAutoLoginCell: SwitchableTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialValues()
    }
    
    private func setInitialValues() {
        rootCell.infoValueLabel.text = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_ROOTURL)
        setLabelStyle(rootCell.infoValueLabel)
        contextCell.infoValueLabel.text = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_CONTEXT)
        setLabelStyle(contextCell.infoValueLabel)
        let shouldAutoLogin = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_AUTO)! == "true"
        isAutoLoginCell.switchItem.setOn(shouldAutoLogin, animated: true)
    }
    
    private func setLabelStyle(label: UITextView) {
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.95, alpha: 1.0).CGColor
        label.layer.cornerRadius = 2.0
    }
    
    // MARK: - Navigation
    
    @IBAction func onClickSave(sender: UIBarButtonItem) {
        DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_ROOTURL, attrValue: rootCell.infoValueLabel.text)
        DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_CONTEXT, attrValue: contextCell.infoValueLabel.text)
        let shouldAutoLogin = isAutoLoginCell.switchItem.on.description
        DbUtil.updateValueFromTable(attrName: DbUtil.ATTR_AUTO, attrValue: shouldAutoLogin)
        self.dismissViewControllerAnimated(true) {
            let topViewController = UIUtil.getTopController()
            if  topViewController is RepoViewController {
                let repoViewController = topViewController as! RepoViewController
                repoViewController.reloadData()
            } else if topViewController is SysObjectViewController {
                let navigationViewController = topViewController!.navigationController! as UINavigationController
                let revealViewController = navigationViewController.revealViewController() as SWRevealViewController
                revealViewController.navigationController!.setNavigationBarHidden(false, animated: true)
                revealViewController.navigationController!.popViewControllerAnimated(true)
                let loginViewController = UIUtil.getTopController() as! LoginViewController
                let anotherNavigationViewController = loginViewController.navigationController! as UINavigationController
                anotherNavigationViewController.popToRootViewControllerAnimated(true)
                let VCs = anotherNavigationViewController.viewControllers
                for vc in VCs {
                    if vc is RepoViewController {
                        let repoViewController = vc as! RepoViewController
                        repoViewController.reloadData()
                    }
                }
            }
        }
    }
}

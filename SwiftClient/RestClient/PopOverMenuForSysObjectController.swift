//
//  PopOverMenuForSysObjectController.swift
//  RestClient
//
//  Created by Song, Michyo on 9/14/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class PopOverMenuForSysObjectController: AbstractPopOverMenuController {
    @IBOutlet weak var miscControlButton: UIButton!
    
    var parentObject: RestObject!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if Context.clickBoard == nil {
            miscControlButton.enabled = false
        } else {
            miscControlButton.enabled = true
        }
    }
    
    @IBAction func onClickMisc(sender: UIButton) {
        self.dismissViewControllerAnimated(true) {
            let topController = UIUtil.getTopController() as! SysObjectViewController
            
            let actionSheet = UIAlertController(
                title: "More...",
                message: "What do you want to do with this object?",
                preferredStyle:  .ActionSheet
            )

            if Context.clickBoard != nil {
                let copyHere = UIAlertAction(title: "Copy Here", style: .Default) { (action: UIAlertAction!) in
                    self.copyHere(self.parentObject)
                }
                actionSheet.addAction(copyHere)
                let moveHere = UIAlertAction(title: "Move Here", style: .Default) { (action: UIAlertAction!) in
                    self.moveHere(self.parentObject)
                }
                actionSheet.addAction(moveHere)
                let linkHere = UIAlertAction(title: "Link Here", style: .Default) { (action: UIAlertAction!) in
                    self.linkHere(self.parentObject)
                }
                actionSheet.addAction(linkHere)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            actionSheet.addAction(cancelAction)
            
            topController.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func copyHere(object: RestObject) {
        printLog("Copy \(Context.clickBoard.getNameWithType()) to \(object.getNameWithType())")
        let topController = UIUtil.getTopController() as! SysObjectViewController
        MiscService.copyTo(object, thisController: topController) {
            topController.refreshData()
        }
    }
    
    private func moveHere(object: RestObject) {
        printLog("Move \(Context.clickBoard.getNameWithType()) to \(object.getNameWithType())")
        let topController = UIUtil.getTopController() as! SysObjectViewController
        MiscService.moveTo(object, thisController: topController) {
            topController.refreshData()
        }
    }
    
    private func linkHere(object: RestObject) {
        printLog("Link \(Context.clickBoard.getNameWithType()) to \(object.getNameWithType())")
        let topController = UIUtil.getTopController() as! SysObjectViewController
        MiscService.linkTo(object, thisController: topController) {
            topController.refreshData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        dismissSelf = true
    }
}

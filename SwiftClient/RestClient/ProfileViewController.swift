//
//  ProfileViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ProfileViewController: AbstractRestObjectInfoViewController {
    
    @IBOutlet var okButon: UIBarButtonItem!
    
    // MARK: - Navigation
    @IBAction func onClickOK(sender: UIBarButtonItem) {
        dissmissSelf()
    }
}

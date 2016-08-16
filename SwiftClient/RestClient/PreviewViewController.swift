//
//  PreviewViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
    var downloadUrl: String!
    var objectId: String!
    var fileUrl: NSURL?
    
    var aiHelper = ActivityIndicatorHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        previewImageView.userInteractionEnabled = true
        previewImageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.navigationController?.navigationBar.hidden = true
        aiHelper.addActivityIndicator(self.view)
        
        loadImage()
    }
    
    // MARK: - Download picture
    func loadImage() {
        aiHelper.startActivityIndicator()
        if FileUtil.isDownloaded(objectId!) {
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                let fileUrl = FileUtil.getFileUrlFromId(self.objectId!)
                self.previewImageView.image = UIImage(data: NSData(contentsOfURL: fileUrl)!, scale: 1)
                self.aiHelper.stopActivityIndicator()
            })
        } else {
            self.downloadPicFromUrl(downloadUrl!)
        }
    }
    
    private func downloadPicFromUrl(url: String) {
        RestService.downloadFile(url, objectId: self.objectId!) { data, error in
            if let e = error {
                ErrorAlert.show(e.message, controller: self)
                return
            }
            if let d = data {
                // set picture to a new one
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.previewImageView.image = UIImage(data: d, scale: 1)
                    self.aiHelper.stopActivityIndicator()
                })
            }
        }
    }
    
    func imageTapped() {
        navigationController?.popViewControllerAnimated(true)
        navigationController?.navigationBar.hidden = false
    }
}

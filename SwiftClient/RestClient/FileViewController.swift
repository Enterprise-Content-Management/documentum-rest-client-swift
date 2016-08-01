//
//  FileViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/6/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import Alamofire

class FileViewController: UIViewController {
    
    // General flags
    var isEditable = false
    var needPreviewDownload = false
    
    // From add object view
    var file: BundleFile?
    
    // From info view
    var objectId: String?
    var objectUrl: String?

    var downloadUrl: String!
    var object: RestObject!
    
    @IBOutlet weak var fileContentTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var aiHelper = ActivityIndicatorHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if(needPreviewDownload) {
            downloadFile()
        } else {
            loadFileContent()
        }
        
        setBorderTextView()
        setTextViewState()
        aiHelper.addActivityIndicator(self.view)
    }
    
    
    private func downloadFile() {
        aiHelper.startActivityIndicator()
        objectId = RestUriBuilder.getObjectId(objectUrl!)
        RestService.getRestObject(objectUrl!) { restObject, error in
            if restObject != nil {
                self.object = restObject
                print("Successfully get object from \(self.objectUrl!)")
                if FileUtil.isDownloaded(self.objectId!) {
                    self.loadFileFromLocal(self.objectId!)
                } else {
                    self.loadFileFromCloud()
                }
            }
        }
    }
    
    private func loadFileContent() {
        aiHelper.startActivityIndicator()
        navigationItem.title = file!.fileName
        
        let path = file!.filePath
        let content = try! String(
            contentsOfFile: path,
            encoding: NSUTF8StringEncoding
        )
        fileContentTextView.text = content
        aiHelper.stopActivityIndicator()
    }
    
    private func loadFileFromCloud() {
        RestServiceEnhance.getDownloadUrl(object!, doAfterDownloaded: self.changeAndDownload)
    }
    
    private func changeAndDownload(url: String, properties: NSDictionary, links: NSArray) {
        self.downloadUrl = url
        self.downloadFileFromUrl(self.downloadUrl!)
    }
    
    private func loadFileFromLocal(objectId: String) {
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            let fileUrl = FileUtil.getFileUrlFromId(self.objectId!)
            let text = NSString(data: NSData(contentsOfURL: fileUrl)!, encoding: NSUTF8StringEncoding)
            self.fileContentTextView.text = text! as String
            self.aiHelper.stopActivityIndicator()
        })
    }
    
    private func downloadFileFromUrl(url: String) {
        RestService.downloadFile(url, objectId: self.objectId!) { data, error in
            if let d = data {
                // set picture to a new one
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    let text = NSString(data: d, encoding: NSUTF8StringEncoding)
                    self.fileContentTextView.text = text! as String
                    self.aiHelper.stopActivityIndicator()
                })
            }
        }
    }
    
    // MARK: - UI Control
    
    private func setBorderTextView() {
        fileContentTextView.layer.borderWidth = 0.5
        fileContentTextView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.95, alpha: 1.0).CGColor
        fileContentTextView.layer.cornerRadius = 2.0
    }
    
    private func setTextViewState() {
        setTextEnable(isEditable)
    }
    
    private func setTextEnable(isEnable: Bool) {
        if isEnable {
            fileContentTextView.editable = true
            fileContentTextView.selectable = true
            saveButton.enabled = true
            saveButton.tintColor = nil
            fileContentTextView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.9).CGColor
        } else {
            fileContentTextView.editable = false
            fileContentTextView.selectable = false
            saveButton.enabled = false
            saveButton.tintColor = UIColor.clearColor()
        }
    }
    
    // MARK: - Gesture
    
    @IBAction func onLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            setTextEnable(true)
        }
    }
    
    // MARK: - Button control
    
    @IBAction func onClickSave(sender: UIBarButtonItem) {
        if needPreviewDownload {
            uploadModifiedFile()
        } else {
            saveToLocalFile()
        }
    }
    
    private func constructAttrDic(object: RestObject) -> Dictionary<String, String> {
        var attrDic: Dictionary<String, String> = [:]
        attrDic["object_name"] = object.getName()
        return attrDic
    }
    
    private func uploadModifiedFile() {
        aiHelper.startActivityIndicator()
        let checkoutUrl = object?.getLink(LinkRel.checkout.rawValue)
        RestService.getPropertiesAndLinks(Alamofire.Method.PUT, url: checkoutUrl!) { properties, links, error in
            self.object?.links.removeAll()
            self.object?.constructLinks(links!)
            
            let json = JsonUtility.getUploadRequestBodyJson(self.constructAttrDic(self.object!))
            
            // TODO: make a alert window to allow choose from minor or major
            let checkinUrl = self.object?.getLink(LinkRel.checkinMajor.rawValue)
            let data = self.fileContentTextView.text.dataUsingEncoding(NSUTF8StringEncoding)
            let type = self.object?.getType()
            RestService.uploadFile(
                checkinUrl!, metadata: json, file: data!, type: type!
            ) { dic, error in
                if dic != nil {
                    print("Successfully check out and check in for file \((self.object?.getName())!).")
                    let object = RestObject(dic: dic!)
                    self.aiHelper.stopActivityIndicator()
                    self.navigationController?.popViewControllerAnimated(true)
                    let infoViewController = self.navigationController?.topViewController as! InfoViewController
                    infoViewController.object = object
                    infoViewController.loadDataForTable()
                    infoViewController.groupedTableView.reloadData()
                }
            }
        }
    }
    
    private func saveToLocalFile() {
        aiHelper.startActivityIndicator()
        let path = NSURL(fileURLWithPath: (file?.filePath)!)
        do {
            try fileContentTextView.text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
        } catch {
            print("Error in writing to file \((file?.fileName)!)")
        }
        aiHelper.stopActivityIndicator()
        navigationController?.popViewControllerAnimated(true)
    }
}

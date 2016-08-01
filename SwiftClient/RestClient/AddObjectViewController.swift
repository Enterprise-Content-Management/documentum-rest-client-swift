//
//  AddObjectViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 5/25/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class AddObjectViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate
{
    var postUrl: String?
    
    var typePickData: [String]?
    let imagePickController: UIImagePickerController = UIImagePickerController()
    var chosenData: NSData? // Really used for upload
    var chosenType: String?
    var isUploadable: Bool = false
    
    var aiHelper = ActivityIndicatorHelper()
    
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var fileNameTextView: UITextView!
    @IBOutlet var filePathLabel: UILabel!
    
    @IBOutlet var chooseDataTableCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manageUploadCell()
        
        picker.dataSource = self
        picker.delegate = self
        imagePickController.delegate = self
        imagePickController.allowsEditing = true
        
        aiHelper.addActivityIndicator(self.view)
        view.bringSubviewToFront(tableView)
    }
    
    private func constructAttrDic() -> Dictionary<String, String> {
        var attrDic: Dictionary<String, String> = [:]
        attrDic["object_name"] = fileNameTextView.text.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return attrDic
    }
    
    // MARK: - Button control
    
    @IBAction func confirmAdd(sender: UIButton) {
        
        let attrDic = self.constructAttrDic()
        aiHelper.startActivityIndicator()
        let type = typePickData![picker.selectedRowInComponent(0)]

        if isUploadable {
            let url = updatePostUrl()
            let json = JsonUtility.getUploadRequestBodyJson(attrDic)
            RestService.uploadFile(
            url, metadata: json, file: self.chosenData!, type: self.chosenType!
            ) { result, error in
                if result != nil {
                    print("Successfully create a new \(type).")
                    self.goBackAndRefresh()
                }
            }
        } else {
            let requestBody = JsonUtility.getUpdateRequestBody(type, attrDic: attrDic)
            RestService.createWithAuth(self.postUrl!, requestBody: requestBody){ result, error in
                if result != nil {
                    print("Successfully create a new \(type).")
                    self.goBackAndRefresh()
                }
            }
        }
    }
    
    private func goBackAndRefresh() {
        aiHelper.stopActivityIndicator()
        self.navigationController?.popViewControllerAnimated(true)
        let controller = self.navigationController?.topViewController as! SysObjectViewController
        controller.needReloadData = true
    }
    
    private func updatePostUrl() -> String {
        let url = postUrl!.stringByReplacingOccurrencesOfString("objects", withString: "documents")
        print("postUrl is now \(url)")
        return url
    }

    @IBAction func cancelAdd(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Pick view control
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.typePickData!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.typePickData![row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.typePickData![row] == "dm_document" {
            isUploadable = true
        } else {
            isUploadable = false
        }
        manageUploadCell()
    }
    
    private func manageUploadCell() {
        
        if isUploadable {
            chooseDataTableCell.hidden = false
        } else {
            chooseDataTableCell.hidden = true
        }
    }
    
    // MARK: - Table view control
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Choose object to upload
    @IBAction func showPhotoLibrary(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            imagePickController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            presentViewController(imagePickController, animated: true, completion: nil)
        }
        chosenType = RestService.MIME_JPEG
    }
    @IBAction func showFiles(sender: UIButton) {
        chosenType = RestService.MIME_TEXT
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName = getImageName(imageUrl.path!)
        let documentDictionary = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        let localPath = documentDictionary.stringByAppendingString(imageName)
        let photoUrl = NSURL(fileURLWithPath:  localPath)
        filePathLabel.text = photoUrl.absoluteString
        print("Photo path: \(photoUrl.absoluteString)")
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        chosenData = UIImageJPEGRepresentation(image, 0.0) // 0.0 is lowest quaility and 1.0 is highest
        
        self.tableView.reloadData()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func getImageName(path: String) -> String {
        let array = path.characters.split("/").map(String.init)
        let last = array.count - 1
        return "/" + array[last]
    }
}
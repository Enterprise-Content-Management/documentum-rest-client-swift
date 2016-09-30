//
//  InfoViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 3/31/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class InfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var groupedTableView: UITableView!
    @IBOutlet weak var previewButton: UIBarButtonItem!
    
    var object: RestObject!
    var comments: [Comment] = []
    let sectionTitles = ["Basic", "Links", "Comments"]
    var shownSections = [0, 2]
    
    var needUpdate: Bool = false

    var mimeType: String = "unknown"
    var objectId: String!
    var downloadUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set agents
        groupedTableView.delegate = self
        groupedTableView.dataSource = self
        
        // Set auto layout for cell
        groupedTableView.estimatedRowHeight = 60
        groupedTableView.rowHeight = UITableViewAutomaticDimension
        
        setImage()
        unshowPreviewButton()

        view.bringSubviewToFront(groupedTableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needUpdate {
            refreshTable()
        }
        
        if downloadUrl == nil {
            if object.getType() == RestObjectType.document.rawValue {
                // Set for preview button
                RestServiceEnhance.getDownloadUrl(object!) { url, properties, links in
                    self.downloadUrl = url
                    self.mimeType = properties["mime_type"] as! String
                    self.objectId = properties["r_object_id"] as! String
                    if self.mimeType == RestService.MIME_JPEG || self.mimeType == RestService.MIME_TEXT {
                        self.showPreviewButton()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if navigationController?.topViewController is SysObjectViewController && needUpdate {
            let sysObjectViewController = navigationController?.topViewController as! SysObjectViewController
            sysObjectViewController.reloadData()
        }
    }
    
    private func setImage() {
        self.infoImageView.image = UIImage(named: "InfoImage")!
    }
    
    private func unshowPreviewButton() {
        previewButton.enabled = false
        previewButton.tintColor = UIColor.clearColor()
    }
    
    private func showPreviewButton() {
        previewButton.enabled = true
        previewButton.tintColor = nil
    }
    
    private func getBasicPair(key: String) -> (String, String) {
        return (key, object.basic[key]!)
    }
    
    private func getBasicPair(key: ObjectProperties) -> (String, String) {
        return (key.rawValue, object.basic[key.rawValue]!)
    }
    
    private func refreshTable() {
        let id = object.getId()
        
        RestService.getRestObject(id) { restObject, error in
            if restObject != nil {
                self.object = restObject!
                self.groupedTableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view control
    private func getDicForSection(section: Int) -> Dictionary<String, String> {
        switch section {
        case 0:
           return object.basic
        case 1:
            return object.links
        default:
            return [:]
        }
    }
    
    private func showComments() -> Bool {
        let type = object.getType()
        let isSysObject = (type == RestObjectType.document.rawValue) || (type == RestObjectType.sysObject.rawValue)
        return isSysObject && shownSections.contains(2)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shownSections.contains(section) {
            switch section {
            case 2:
                if showComments() {
                    return comments.count
                }
            default:
                return getDicForSection(section).count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 && showComments() {
            return sectionTitles[2]
        }
        if section != 2 && shownSections.contains(section) {
            return sectionTitles[section]
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section

        if section == 0 || section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InfoItemTableViewCell", forIndexPath: indexPath) as! InfoItemTableViewCell
            let dic = getDicForSection(section)
            let key = dic.keys.sort()[indexPath.row]
            cell.initCell(key, value: dic[key]!)
            return cell
        } else if section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentItemTableViewCell", forIndexPath: indexPath) as! CommentItemTableViewCell
            cell.initCell(comments[indexPath.row])
            return cell
        }
        return UITableViewCell.init()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 160
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 160
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Button Control
    @IBAction func onClickPreview(sender: UIBarButtonItem) {
        showPreview()
    }
    
    private func showPreview() {
        if mimeType == RestService.MIME_JPEG {
            self.previewPic(downloadUrl, id: objectId)
        } else if mimeType == RestService.MIME_TEXT {
            self.previewFile()
        }
    }
    
    private func previewPic(url: String, id: String) {
        let picViewController = UIUtil.getViewController("PicViewController") as! PreviewViewController
        picViewController.downloadUrl = url
        picViewController.objectId = id
        self.navigationController?.pushViewController(picViewController, animated: true)
    }
    
    private func previewFile() {
        let textViewController = UIUtil.getViewController("FileViewController") as! FileViewController
        textViewController.needPreviewDownload = true
        textViewController.objectUrl = object.getLink(LinkRel.selfRel.rawValue)
        self.navigationController?.pushViewController(textViewController, animated: true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "UpdateAttribute" {
            let updateViewController = segue.destinationViewController as! UpdateViewController
            if let selectedItemCell = sender as? InfoItemTableViewCell {
                let attrName = selectedItemCell.infoNameLabel.text
                updateViewController.navigationItem.title = attrName!
                let attrValue = selectedItemCell.infoValueLabel.text
                updateViewController.value = attrValue
    
                updateViewController.editUrl = object.links[LinkRel.edit.rawValue]!
                updateViewController.type = object.getType()

                self.needUpdate = true
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "UpdateAttribute" {
            if object?.links[LinkRel.edit.rawValue] == nil {
                return false
            }
            if let cell = sender as? InfoItemTableViewCell {
                let indexPath = groupedTableView.indexPathForCell(cell)!
                // Only basic attribute excepting type and id could update.
                if indexPath.section == 0 && indexPath.row > 1 {
                    return true
                }
            }
        }
        return false
    }
}

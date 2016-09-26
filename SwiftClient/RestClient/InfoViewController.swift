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
    var info: Array<(String, Array<(String, String)>)> = [
        ("Basic", [])
    ]
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
        
        loadDataForTable()
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
    
    func loadDataForTable() {
        info.removeAll()
        
        var basicArray = [] as Array<(String, String)>
        basicArray.append(getBasicPair(ObjectProperties.ID))
        basicArray.append(getBasicPair(ObjectProperties.TYPE))
        basicArray.append(getBasicPair(ObjectProperties.NAME))
        basicArray.append(getBasicPair(ObjectProperties.UPDATED))
        basicArray.append(getBasicPair(ObjectProperties.PUBLISHED))
        info.append(("Basic", basicArray))

        // Unshown links
//        let linkDic = object?.links
//        var linkArray = [] as Array<(String, String)>
//        for link in linkDic! {
//            linkArray.append((RestObject.getRawLinkRel(link.0), link.1))
//        }
//        info.append(("Links", linkArray))
    }
    
    private func getBasicPair(key: String) -> (String, String) {
        return (key, object.basic[key]!)
    }
    
    private func refreshTable() {
        let id = info[0].1[0].1
        
        RestService.getRestObject(id) { restObject, error in
            if restObject != nil {
                self.object = restObject!
                self.loadDataForTable()
                self.groupedTableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view control
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.info.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.info[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoItemTableViewCell", forIndexPath: indexPath) as! InfoItemTableViewCell
        let cellInfo = self.info[indexPath.section].1[indexPath.row]
        
        cell.initCell(cellInfo.0, value: cellInfo.1)        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return info[section].0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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

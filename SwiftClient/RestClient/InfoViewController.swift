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

class InfoViewController: UITableViewController {
    
    @IBOutlet weak var previewButton: UIBarButtonItem!

    var object: RestObject!
    var comments: [RestObject] = []
    let sectionTitles = ["Basic", "Links", "Comments"]
    var shownSections = [0, 2]
    
    var needUpdate: Bool = false

    var mimeType: String = "unknown"
    var objectId: String!
    var downloadUrl: String!
    
    var commentPage: Int = 1
    var isCommentLastPage: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set auto layout for cell
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension

        unshowPreviewButton()

        view.bringSubviewToFront(tableView)
        
        if showComments() {
            loadComments()
        }
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
                self.comments.removeAll()
                self.loadComments()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Data
    
    func loadComments() {
        let aiHelper = ActivityIndicatorHelper()
        aiHelper.addActivityIndicator(tableView)
        aiHelper.startActivityIndicator()
        
        let commentService = CommentCollectionService()
        commentService.url = object.getLink(LinkRel.comments.rawValue)!
        commentService.getCommentsAndReplies(commentPage, thisViewController: self) { comments, isLastPage in
            self.isCommentLastPage = isLastPage
            for comment in comments {
                self.comments.append(comment)
            }
            // set for ui
            self.view?.bringSubviewToFront(self.tableView)
            // refresh list view to show all items
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                self.tableView.reloadData()
                aiHelper.stopActivityIndicator()
            })
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 && showComments() {
            return sectionTitles[2]
        }
        if section != 2 && shownSections.contains(section) {
            return sectionTitles[section]
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 && showComments() {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentFootView") as! CommentFootView
            cell.initCell()
            return cell
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 && showComments() {
            return CommentFootView.height
        }
        return tableView.sectionFooterHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section

        if section == 0 || section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InfoItemTableViewCell", forIndexPath: indexPath) as! InfoItemTableViewCell
            let dic = getDicForSection(section)
            let key = dic.keys.sort()[indexPath.row]
            cell.initCell(key, value: dic[key]!)
            return cell
        } else if section == 2 {
            let cellObject = comments[indexPath.row] as! Comment
            if cellObject.getType() == RestObjectType.comment.rawValue {
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentItemTableViewCell", forIndexPath: indexPath) as! CommentItemTableViewCell
                cell.initCell(cellObject)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ReplyItemTableViewCell", forIndexPath: indexPath) as! ReplyItemTableViewCell
                cell.initCell(cellObject)
                return cell
            }
        }
        return UITableViewCell.init()
    }
    
    private func getHeightForComment(indexPath: NSIndexPath) -> CGFloat {
        let isComment = comments[indexPath.row].getType() == RestObjectType.comment.rawValue
        if isComment {
            return CommentItemTableViewCell.height
        } else {
            return ReplyItemTableViewCell.height
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return getHeightForComment(indexPath)
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return getHeightForComment(indexPath)
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
    }
    
    // MARK: - Bar Button Control    
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
                let indexPath = tableView.indexPathForCell(cell)!
                // Only basic attribute excepting type and id could update.
                if indexPath.section == 0 && indexPath.row > 1 {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Comments Misc
    
    @IBAction func onClickNewComment(sender: UIButton) {
        showCommentDialog()
    }
    
    private func showCommentDialog() {
        let commentController = UIAlertController(title: "Add new comment", message: "Please input your comment.", preferredStyle: .Alert)
        commentController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "comment..."
        }
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction!) -> Void in
            let content = commentController.textFields!.first!.text!
            let commentsUrl = self.object.getLink(LinkRel.comments.rawValue)!
            let requesBody = ["content-value": content]
            RestService.createWithAuth(commentsUrl, requestBody: requesBody) { dic, error in
                if dic != nil {
                    let comment = Comment(singleDic: dic!)
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        commentController.addAction(sendAction)
        commentController.addAction(cancelAction)
        presentViewController(commentController, animated: true, completion: nil)
    }
    
    private func getRelatedObjectIndex(sender: UIButton) -> Int {
        let cell = sender.superview?.superview as! CommentItemTableViewCell
        return tableView.indexPathForCell(cell)!.row
    }
    
    @IBAction func onClickReply(sender: UIButton) {
        showReplyDialog(sender)
    }
    
    private func showReplyDialog(sender: UIButton) {
        let replyController = UIAlertController(title: "Reply to comment", message: "Please input your reply", preferredStyle: .Alert)
        replyController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "reply..."
        }
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction!) -> Void in
            let content = replyController.textFields!.first!.text!
            let index = self.getRelatedObjectIndex(sender)
            let repliesUrl = self.comments[index].getLink(LinkRel.replies.rawValue)!
            let requestBody = ["content-value": content]
            RestService.createWithAuth(repliesUrl, requestBody: requestBody) { dic, error in
                if dic != nil {
                    let reply = Comment(singleDic: dic!)
                    self.comments.insert(reply, atIndex: index + 1)
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        replyController.addAction(sendAction)
        replyController.addAction(cancelAction)
        presentViewController(replyController, animated: true, completion: nil)
    }

    @IBAction func onClickDelete(sender: UIButton) {
    }
}

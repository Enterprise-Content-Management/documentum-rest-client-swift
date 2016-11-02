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
    
    var isUserCanComment: Bool = false
    let aiHelper = ActivityIndicatorHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unshowPreviewButton()

        view.bringSubviewToFront(tableView)
        aiHelper.addActivityIndicator(tableView)
        
        if showComments() {
            initData()
        }
    }
    
    // Determine this user's permission on object and load comments if any.
    private func initData() {
        RestService.getPermissions(object.getLink(LinkRel.permissions)!) { json, error in
            if let error = error {
                ErrorAlert.show(error.errorCode, controller: self, dismissViewController: false)
            } else if let permissions = json?.dictionary {
                let basicPermission = permissions["basic-permission"]!.stringValue
                var log: String = "User \(RestUriBuilder.getCurrentUserName()) has basic permission level \(basicPermission) on this object, so he/she "
                if BasicPermission.getPermissionInt(basicPermission) >= BasicPermission.RELATE.rawValue {
                    log += "can "
                    self.isUserCanComment = true
                    self.loadComments()
                    self.tableView.reloadData()
                } else {
                    log += "can not "
                }
                printLog(log + "comment on this object.")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if needUpdate {
            refreshTable {
                self.decidePreviewButtonShowOrNot()
            }
        } else {
            decidePreviewButtonShowOrNot()
        }
    }
    
    private func decidePreviewButtonShowOrNot() {
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
    
    private func refreshTable(afterWards: Void -> Void) {
        let selfLink = object.getLink(LinkRel.selfRel)!
        
        RestService.getRestObject(selfLink) { restObject, error in
            if restObject != nil {
                self.object = restObject!
                self.comments.removeAll()
                self.loadComments()
                self.tableView.reloadData()
                afterWards()
            }
        }
    }
    
    // MARK: - Data
    
    func loadComments() {
        aiHelper.startActivityIndicator()
        
        let commentService = CommentCollectionService()
        commentService.url = object.getLink(LinkRel.comments)!
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
                self.aiHelper.stopActivityIndicator()
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
        let hasCommentsLink = object.getLink(LinkRel.comments) != nil
        return hasCommentsLink && shownSections.contains(2)
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
        if section == 2 && showComments() && isUserCanComment {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentFootView") as! CommentFootView
            cell.initCell()
            return cell.contentView
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 && showComments() && isUserCanComment {
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if comments.isEmpty || indexPath.row >= comments.count {
            return false
        }
        let comment = comments[indexPath.row] as! Comment
        if indexPath.section == 2 && comment.getCanDelete() {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            showDeleteDialog(indexPath)
        }
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
        textViewController.objectUrl = object.getLink(LinkRel.selfRel)
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
        } else if segue.identifier == "ShowReplies"{
            let repliesViewController = segue.destinationViewController as! RepliesViewController
            let cell = sender as! ReplyItemTableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            repliesViewController.parentComment = comments[indexPath.row] as! Comment
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if sender is InfoItemTableViewCell {
            if identifier == "UpdateAttribute" {
                if object?.links[LinkRel.edit.rawValue] == nil {
                    return false
                }
                if let cell = sender as? InfoItemTableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    // Only basic attribute excepting type and id could update.
                    if indexPath.section == 0 && indexPath.row == 1 {
                        return true
                    }
                }
            }
            return false
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
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
            let commentsUrl = self.object.getLink(LinkRel.comments)!
            let requesBody = ["content-value": content]
            self.aiHelper.startActivityIndicator()
            RestService.createWithAuth(commentsUrl, requestBody: requesBody) { dic, error in
                if let error = error {
                    if error.status == 403 {
                        ErrorAlert.show(error.message, controller: self, dismissViewController: false)
                        self.isUserCanComment = false
                        self.tableView.reloadData()
                    }
                } else if dic != nil {
                    let comment = Comment(singleDic: dic!)
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }
                self.aiHelper.stopActivityIndicator()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        commentController.addAction(sendAction)
        commentController.addAction(cancelAction)
        presentViewController(commentController, animated: true, completion: nil)
    }
    
    private func getRelatedObjectIndex(sender: UIButton) -> NSIndexPath {
        let cell = sender.superview?.superview as! CommentItemTableViewCell
        return tableView.indexPathForCell(cell)!
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
            let index = self.getRelatedObjectIndex(sender).row
            let repliesUrl = self.comments[index].getLink(LinkRel.replies)!
            let requestBody = ["content-value": content]
            RestService.createWithAuth(repliesUrl, requestBody: requestBody) { dic, error in
                if dic != nil {
                    let reply = Comment(singleDic: dic!)
                    reply.setParentComment(self.comments[index] as? Comment)
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
        showDeleteDialog(getRelatedObjectIndex(sender))
    }
    
    private func showDeleteDialog(indexPath: NSIndexPath) {
        let showingMessage: String = "Are you sure to delete this comment?"
        let alertController = UIAlertController(
            title: "Delete Warning",
            message: showingMessage,
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .Cancel) { (action: UIAlertAction!) in
            self.cancelDelete(indexPath)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) in
            self.doDelete(indexPath)
        }
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func doDelete(indexPath: NSIndexPath) {
        aiHelper.startActivityIndicator()
        let object = comments[indexPath.row] as RestObject
        
        if object.getLink(LinkRel.delete) != nil {
            let deletLink = object.getLink(LinkRel.delete)!
            RestService.deleteWithAuth(deletLink) { result, error in
                if result != nil {
                    printLog("Successfully delete this comment from cloud.")
                    self.aiHelper.stopActivityIndicator()
                    
                    self.comments.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    
                    let index = indexPath.row
                    if object.getType() == RestObjectType.comment.rawValue && index < self.comments.count {
                        while (index < self.comments.count && self.comments[index].getType() == RestObjectType.reply.rawValue) {
                            self.comments.removeAtIndex(index)
                            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Fade)
                        }
                    }
                }
            }
        }
    }
    
    private func cancelDelete(indexPath: NSIndexPath) {
        printLog("Cancel deletion.")
        self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
    }
}

enum BasicPermission: Int {
    case NULL = 0
    case NONE = 1
    case BROWSE = 2
    case READ = 3
    case RELATE = 4
    case VERSION = 5
    case WRITE = 6
    case DELETE = 7
    
    static func getPermissionInt(permission: String) -> Int {
        let upperCase = permission.uppercaseString
        switch upperCase {
        case "NULL":
            return 0
        case "NONE":
            return 1
        case "BROWSE":
            return 2
        case "READ":
            return 3
        case "RELATE":
            return 4
        case "VERSION":
            return 5
        case "WRITE":
            return 6
            case "DELETE":
                return 7
        default:
            return -1
        }
    }
}

//
//  RepliesViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 10/21/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class RepliesViewController: AbstractCollectionViewController {
    
    var parentComment: Comment!
    
    override func viewDidLoad() {
        setUI()
        loadData()
        tableView.reloadData()
    }
    
    private func setUI() {
        navigationItem.title = "Comment from " + parentComment.getAuthorName()
        initRefreshControl()
    }
    
    override func loadData(page: NSInteger = 1) {
        let repliesUrl = parentComment.getLink(LinkRel.replies)!
        let commentService = CommentCollectionService(url: repliesUrl)
        commentService.getEntries(page, thisViewController: self) { result, isLastPage in
            if result.isEmpty {
            }
            for object in result {
                self.objects.append(object)
            }
            self.tableView.reloadData()
            self.aiHelper.stopActivityIndicator()
        }
    }
    
    // MARK: - TableView control
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentItemTableViewCell", forIndexPath: indexPath) as! CommentItemTableViewCell
            cell.initCell(parentComment)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReplyItemTableViewCell", forIndexPath: indexPath) as! ReplyItemTableViewCell
            let object = objects[indexPath.row - 1] as! Comment
            cell.initCell(object)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count + 1
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CommentItemTableViewCell.height
        } else {
            return ReplyItemTableViewCell.height
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CommentItemTableViewCell.height
        } else {
            return ReplyItemTableViewCell.height
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { action, indexPath in
            let replyIndex = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            self.showAlert(indexPath, type: self.objects[replyIndex.row].getType(), name: self.objects[replyIndex.row].getName())
            tableView.setEditing(false, animated: false)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        return [deleteAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        if indexPath.row != 0 {
            let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RepliesViewController") as! RepliesViewController
            nextViewController.parentComment = objects[indexPath.row - 1] as! Comment
            self.navigationController!.pushViewController(nextViewController, animated: true)
        }
    }
    
    // MARK: - Button Control
    @IBAction func onClickReply(sender: UIButton) {
        showCommentDialog()
    }
    
    private func showCommentDialog() {
        let commentController = UIAlertController(title: "Reply to comment", message: "Please input your comment.", preferredStyle: .Alert)
        commentController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "comment..."
        }
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction!) -> Void in
            let content = commentController.textFields!.first!.text!
            let commentsUrl = self.parentComment.getLink(LinkRel.replies)!
            let requesBody = ["content-value": content]
            self.aiHelper.startActivityIndicator()
            RestService.createWithAuth(commentsUrl, requestBody: requesBody) { dic, error in
                if let error = error {
                    ErrorAlert.show(error.message, controller: self, dismissViewController: false)
                    return
                } else if dic != nil {
                    let comment = Comment(singleDic: dic!)
                    self.objects.append(comment)
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
    
    @IBAction func onClickDelete(sender: UIButton) {
        let cell = sender.superview?.superview as! CommentItemTableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        showDeleteDialog(indexPath)
    }
    
    private func showDeleteDialog(indexPath: NSIndexPath) {
        let showingMessage: String = "Are you sure to delete this root comment?"
        let alertController = UIAlertController(
            title: "Delete Warning",
            message: showingMessage,
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .Cancel) { (action: UIAlertAction!) in
            self.cancelDelete(indexPath)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) in
            self.deleteRootComment()
        }
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func deleteRootComment() {
        aiHelper.startActivityIndicator()
        let object = parentComment
        
        if object.getLink(LinkRel.delete) != nil {
            let deletLink = object.getLink(LinkRel.delete)!
            RestService.deleteWithAuth(deletLink) { result, error in
                if result != nil {
                    printLog("Successfully delete this comment from cloud.")
                    self.aiHelper.stopActivityIndicator()
                    self.navigationController?.popViewControllerAnimated(true)
                    let topViewController = self.navigationController?.topViewController
                    if let infoViewController = topViewController as? InfoViewController {
                        infoViewController.needUpdate = true
                    } else if let repliesViewController = topViewController as? RepliesViewController {
                        repliesViewController.needReloadData = true
                    }
                }
            }
        }
    }
    
    internal override func doDelete(indexPath: NSIndexPath) {
        aiHelper.startActivityIndicator()
        let object = objects[indexPath.row - 1]
        
        if object.getLink(LinkRel.delete) != nil {
            let deletLink = object.getLink(LinkRel.delete)!
            RestService.deleteWithAuth(deletLink) { result, error in
                if result != nil {
                    printLog("Successfully delete this reply from cloud.")
                    self.objects.removeAtIndex(indexPath.row - 1)
                    self.tableView.reloadData()
                    self.aiHelper.stopActivityIndicator()
                }
            }
        }
    }
    
    private func cancelDelete(indexPath: NSIndexPath) {
        printLog("Cancel deletion.")
        self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
    }
}

//
//  FilesViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 6/6/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class FilesViewController: ListViewController {
    
    var files = [BundleFile]()
    var filtedFiles = [BundleFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFilePaths()
        self.tableView.reloadData()
    }
    
    func getFilePaths() {
        getFilesOfType("txt")
        getFilesOfType("rtf")
    }
    
    private func getFilesOfType(type: String) {
        let paths = NSBundle.mainBundle().pathsForResourcesOfType(type, inDirectory: nil)
        let manager = NSFileManager.defaultManager()
        for path in paths {
            let name = manager.displayNameAtPath(path)
//            let attrs = try! NSFileManager.defaultManager().attributesOfItemAtPath(path)
            files.append(BundleFile(name: name, path: path, type: type))
        }
    }
    
    // MARK: - UI control
    private func setNavigationBar() {
        self.navigationController?.navigationItem.backBarButtonItem?.enabled = false
    }
    
    // MARK: - Search handling
    override func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filtedFiles = files.filter { file in
            return file.fileName.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive() {
            return filtedFiles.count
        }
        return files.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FileItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FileItemTableViewCell
        
        let file: BundleFile
        if self.isSearchActive() {
            file = self.filtedFiles[indexPath.row]
        } else {
            file = self.files[indexPath.row]
        }
        
        cell.fileNameLabel.text = file.fileName
        cell.filePathLabel.text = file.filePath
        
        return cell
    }

    // Handle shift operation on single item
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Shift to left means deleting this item
        if editingStyle == .Delete {
            
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let fileViewController = FileUtil.getViewController("FileViewController") as! FileViewController
            fileViewController.isEditable = true
            fileViewController.file = self.files[indexPath.row]
            self.navigationController?.pushViewController(fileViewController, animated: true)
        }
        editAction.backgroundColor = UIColor.blueColor()
        return [editAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let filePath = files[indexPath.row].filePath
        let fileData = NSFileManager.defaultManager().contentsAtPath(filePath)
        
        navigationController?.popViewControllerAnimated(true)
        let addViewController = navigationController!.topViewController as! AddObjectViewController
    
        addViewController.chosenType = RestService.MIME_TEXT
        addViewController.chosenData = fileData
        addViewController.filePathLabel.text = filePath
        addViewController.tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "ShowContent" {
            let fileViewController = segue.destinationViewController as! FileViewController
            if let infoButton = sender as? UIButton {
                let selectedCell = infoButton.superview?.superview as! FileItemTableViewCell
                let indexPath = tableView.indexPathForCell(selectedCell)!
                let selectedItem = files[indexPath.row]
                // path this information to cabinetviewcontroller
                fileViewController.file = selectedItem
                fileViewController.isEditable = false
                fileViewController.needPreviewDownload = false
            }
        }
    }
    
}

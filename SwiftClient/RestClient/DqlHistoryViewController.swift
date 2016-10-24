//
//  DqlHistoryViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 10/24/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class DqlHistoryViewController: UITableViewController, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    @IBOutlet weak var footView: UILabel!
    @IBOutlet weak var clearBarButton: UIBarButtonItem!

    
    // Properties for search bar
    let searchController = UISearchController(searchResultsController: nil)
    
    var histories: [DqlHistory] = []
    var filteredHistories: [DqlHistory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSearchBar()
        loadData()
        tableView.reloadData()
        
        // Enable swipe right to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.setHidesBackButton(true, animated: true)
        
        tableView.tableFooterView = footView
        IconHelper.setIconForBarButton(clearBarButton, iconName: .TrashO)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        setSearchBarOffset()
        // Enable swipe right to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func initSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    private func setSearchBarOffset() {
        if let searchBar = tableView.tableHeaderView {
            if tableView.contentOffset == CGPoint(x: 0, y: 0) {
                let searchBarHeight = searchBar.frame.size.height
                tableView.contentOffset = CGPointMake(0, searchBarHeight)
            }
        }
    }
    
    func loadData() {
        for row in DbUtil.getAllDqlHistories() {
            let history = DqlHistory(id: row[DbUtil.id], time: row[DbUtil.time], dql: row[DbUtil.dql])
            histories.append(history)
        }
        setFooter()
    }
    
    func setFooter() {
        if histories.isEmpty {
            footView.text = "- No History -"
        } else {
            footView.text = "- \(histories.count) in total."
        }
    }
    
    func refreshTable() {
        tableView.reloadData()
        setFooter()
    }
    
    // MARK: - Table View controll
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = histories[indexPath.row].dql
        cell.detailTextLabel?.text = histories[indexPath.row].time
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        
        let dql: String
        if searchController.active && searchController.searchBar.text != "" {
            dql = filteredHistories[indexPath.row].dql
        } else {
            dql = histories[indexPath.row].dql
        }
        
        let dqlViewController = UIUtil.getViewController("DqlViewController") as! DqlViewController
        dqlViewController.dql = dql
        dqlViewController.needReloadData = true
        navigationController?.pushViewController(dqlViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            showDeleteDialog(indexPath)
        }
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
        DbUtil.deleteDqlHistory(histories[indexPath.row].id)
        histories.removeAtIndex(indexPath.row)
        refreshTable()
    }
    
    private func cancelDelete(indexPath: NSIndexPath) {
        printLog("Cancel deletion.")
        self.tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: true)
    }
    
    // MARK: - Search handling
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredHistories = histories.filter { history in
            return history.dql.lowercaseString.containsString(searchText.lowercaseString)
        }
        refreshTable()
    }
    
    // MARK: - Button Control
    @IBAction func onClickClear(sender: UIBarButtonItem) {
        for history in histories {
            DbUtil.deleteDqlHistory(history.id)
        }
        histories.removeAll()
        refreshTable()
    }
}

struct DqlHistory {
    let id: Int64
    let time: String
    let dql: String
}
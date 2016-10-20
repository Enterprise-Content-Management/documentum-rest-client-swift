//
//  RepoViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 3/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class RepoViewController: AbstractCollectionViewController {
    
    // MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var footView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setFootViewWithAi(footView)
        setBarButtons()
    
        loadData()
        
        // Set side menu toggle
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let rootUrl = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_ROOTURL)!
        navigationItem.title = rootUrl.substringFromIndex(rootUrl.startIndex.advancedBy(5)) + "/repositories"
    }
    
    func setBarButtons() {
        IconHelper.setIconForBarButton(menuButton, iconName: .Navicon)
    }
    
    // MARK: Rest service control
    override func loadData(page: NSInteger = 1) {
        super.loadData()
        
        let ai: ActivityIndicatorHelper
        if page == 1 {
            ai = aiHelper
        } else {
            ai = footAiHelper
        }
        ai.startActivityIndicator()
        let reposSerivce = RepositoryCollectionService()
        reposSerivce.getEntries(page, thisViewController: self) { repos, isLastPage in
            self.isLastPage = isLastPage
            for repo in repos {
                self.objects.append(repo)
            }
            // set for ui
            self.view?.bringSubviewToFront(self.tableView)
            ai.stopActivityIndicator()

            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "AskLogin" {
            if let cell = sender as? ItemTableViewCell {
                let indexPath = tableView.indexPathForCell(cell)!
                let selectedItem = objects[indexPath.row]
                Context.repo = selectedItem as RestObject
            }
        }
    }
}

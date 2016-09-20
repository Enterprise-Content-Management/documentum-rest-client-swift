//
//  RepoViewController.swift
//  RestClient
//
//  Created by Song, Michyo on 3/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class RepoViewController: ListViewController {
    
    // MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var footView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setFootViewWithAi(footView)
        
        self.loadData()
        
        // Set side menu toggle
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
                let photo = UIImage(named: "CabinetImage")!
                let item = Item(url: repo.getId(), fileType: repo.getType(), fileName: repo.getName(), photo: photo)
                self.items.append(item)
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

//
//  IssuesViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

class IssuesViewController: ListViewController<IssueCell> {

    override var cellName: String { return "IssueCell" }
    
    @IBOutlet var collectionView_ : UICollectionView!
    @IBOutlet override var collectionView: UICollectionView! {
        get {
            return collectionView_
        }set {
            collectionView_ = newValue
        }
    }
    
    override func viewDidLoad() {
        api = App.api.repoIssues(owner: owner, repo: repo)
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first,
            let viewController = segue.destination as? IssueDetailViewController {
            let issue = dataSource[indexPath.item]
            viewController.issue = issue
        }
    }

}

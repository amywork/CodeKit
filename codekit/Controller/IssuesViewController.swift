//
//  IssuesViewController.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.

import UIKit

class IssuesViewController: ListViewController<IssueCell> {
   
    override var cellName: String { return "IssueCell" }
    
    @IBOutlet var collectionView_: UICollectionView!
    
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowIssueDetailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first,
            let viewConroller = segue.destination as? IssueDetailViewController {
            let issue = dataSource[indexPath.item]
            viewConroller.issue = issue
            viewConroller.reloadIssue = { [weak self] (issue: Model.Issue) in
                guard let `self` = self else { return }
                guard let index = self.dataSource.index(of: issue) else { return }
                self.dataSource[index] = issue
                let indexPath = IndexPath(item: index, section: 0)
                self.collectionView.reloadItems(at: [indexPath])
            }
        } else if let navigationController = segue.destination as? UINavigationController,
            let createIssueViewController = navigationController.topViewController as? CreateIssueViewController {
            createIssueViewController.repo = repo
            createIssueViewController.owner = owner
        }
    }
  
    @IBAction func unwindFromCreate(_ segue: UIStoryboardSegue) {
        if let createViewController = segue.source as? CreateIssueViewController, let createdIssue = createViewController.createdIssue {
            dataSource.insert(createdIssue, at: 0)
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            
        }
    }
 
}

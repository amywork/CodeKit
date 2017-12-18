//
//  IssueDetailViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit


class IssueDetailViewController: ListViewController<IssueCommentCell> {

    override var cellName: String { return "IssueCommentCell" }
   
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var collectionView_: UICollectionView!
    @IBOutlet override var collectionView: UICollectionView! {
        get {
            return collectionView_
        }
        set {
            collectionView_ = newValue
        }
    }
    
    var headerSize: CGSize = CGSize.zero
    
    var issue: Model.Issue! {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        api = App.api.issueComments(owner: owner, repo: repo, number: issue.number)
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IssueDetailHeaderView", for: indexPath) as? IssueDetailHeaderView ?? IssueDetailHeaderView()
            return headerView
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreFooterView", for: indexPath) as? LoadMoreFooterView ?? LoadMoreFooterView()
            loadMoreCell = footerView
            return footerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if headerSize == CGSize.zero {
            headerSize = IssueDetailHeaderView.headerSize(issue: issue, width: collectionView.frame.width)
        }
        return headerSize
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
    }
    
}

//
//  IssueDetailViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
import Alamofire


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
    
    var reloadIssue: ((Model.Issue) -> Void)?
    
    override func viewDidLoad() {
        api = App.api.issueComments(owner: owner, repo: repo, number: issue.number)
        super.viewDidLoad()
        title = "# issue :: \(issue.number)"
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IssueDetailHeaderView", for: indexPath) as? IssueDetailHeaderView ?? IssueDetailHeaderView()
            headerView.update(data: issue)
            headerView.stateButton.addTarget(self, action: #selector(stateButtonTapped), for: .touchUpInside)
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
        send()
    }
    
    @objc func stateButtonTapped() {
        changeState()
    }
}

extension IssueDetailViewController {
    func addComment(comment: Model.Comment) {
        let newIndexPath = IndexPath(item: dataSource.count, section: 0)
        dataSource.append(comment)
        collectionView.insertItems(at: [newIndexPath])
        collectionView.scrollToItem(at: newIndexPath, at: .bottom, animated: true)
    }
    
    func send() {
        guard let comment = commentTextField.text else { return }
        App.api.createComment(owner: owner, repo: repo, number: issue.number, comment: comment)
        { [weak self] (response: DataResponse<Model.Comment>) in
            switch response.result {
            case .success(let comment):
                self?.addComment(comment: comment)
                self?.commentTextField.text = ""
                self?.commentTextField.resignFirstResponder()
            case .failure:
                self?.commentTextField.resignFirstResponder()
                break
            }
        }
    }
    
    func changeState() {
        
    }
}

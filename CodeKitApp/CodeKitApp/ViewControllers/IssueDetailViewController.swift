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
   
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
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
    
    var reloadIssue: ((Model.Issue) -> Void)?
    var issue: Model.Issue! {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotification()
    }
    
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
        switch issue.state {
        case .open:
            App.api.closeIssue(owner: owner,
                               repo: repo,
                               number: issue.number,
                               issue: issue,
                               completionHandler:
                { [weak self] (response: DataResponse<Model.Issue>) in
                    switch response.result {
                    case .success(let issue):
                        self?.issue = issue
                        self?.reloadIssue?(issue)
                    case .failure(let error):
                        print(error)
                    }
            })
        case .closed:
            App.api.openIssue(owner: owner,
                               repo: repo,
                               number: issue.number,
                               issue: issue,
                               completionHandler:
                { [weak self] (response: DataResponse<Model.Issue>) in
                    switch response.result {
                    case .success(let issue):
                        self?.issue = issue
                        self?.reloadIssue?(issue)
                    case .failure(let error):
                        print(error)
                    }
            })
        }
        
    }

}

extension IssueDetailViewController {
    
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name.UIKeyboardWillChangeFrame,
            object: nil,
            queue: nil) { [weak self] (noti: Notification) in
                guard let `self` = self else { return }
                guard let keyboardBounds = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
                guard let animationDuration = noti.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
                guard let animationCurve = noti.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
                let animationOptions = UIViewAnimationOptions(rawValue: animationCurve)
                let keyboardHeight = keyboardBounds.height
                let inputBottom = self.view.frame.height - keyboardBounds.origin.y
                var inset = self.collectionView.contentInset
                inset.bottom = inputBottom + 80
                self.collectionView.contentInset = inset
                self.inputViewBottomConstraint.constant = inputBottom
                UIView.animate(withDuration: animationDuration,
                               delay: 0,
                               options: animationOptions,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil)
        }
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

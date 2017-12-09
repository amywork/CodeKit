//
//  IssueDetailViewController.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 4..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxKeyboard

class IssueDetailViewController: UIViewController {
    
    typealias CommentSectionModel = SectionModel<Int, Model.Comment>
    typealias DataSourceType = RxCollectionViewSectionedReloadDataSource<CommentSectionModel>
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    let estimateCell: CommentCell = CommentCell.cellFromNib
    let refreshControl = UIRefreshControl()
    var issue: Model.Issue!
    var loadMoreCell: LoadMoreCell?
    var disposeBag: DisposeBag = DisposeBag()
    var header: BehaviorSubject<IssueDetailHeaderCell> = BehaviorSubject(value: IssueDetailHeaderCell())
    var headerSize: CGSize = CGSize.zero
    var parentViewReload: PublishSubject<Model.Issue>?
    lazy var loader: IssuesDetailLoader =  { [unowned self] in
        return IssuesDetailLoader(issue: self.issue)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    func setup() {
        collectionView.register(UINib(nibName: "CommentCell", bundle: nil), forCellWithReuseIdentifier: "CommentCell")
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        self.title = "\(owner)/\(repo)"
    }
}

extension IssueDetailViewController {
    func bind() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        loader.bind()
        loader.datasource
            .bind(to: collectionView.rx.items(dataSource: createDatasource()))
            .disposed(by: disposeBag)
        loader.register(refreshControl: refreshControl)
        loader.registerLoadMore(collectionView: collectionView)
        
        header.asObservable().skip(1).share().subscribe(onNext: { [weak self] header in
            guard let `self` = self else { return }
            header.update(data: self.issue)
            self.loader.stateButtonTapSubject.onNext(header.stateButton.rx.tap.asObservable())
            
        }).disposed(by: disposeBag)
        
        if let reload = parentViewReload {
            loader.issueChangedObservable.bind(to: reload).disposed(by: disposeBag)
        }
        
        // 키보드 높이에 맞춰서 컨텐츠 높이도 변경.
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
                var actualKeyboardHeight = keyboardVisibleHeight
                if #available(iOS 11.0, *), keyboardVisibleHeight > 0 {
                    actualKeyboardHeight -= self.view.safeAreaInsets.bottom
                }
                
                self.inputViewBottomConstraint.constant = actualKeyboardHeight
                
                self.view.setNeedsLayout()
                UIView.animate(withDuration: 0) {
                    self.collectionView.contentInset.bottom = keyboardVisibleHeight + 46
                    self.collectionView.scrollIndicatorInsets.bottom = self.collectionView.contentInset.bottom
                    self.view.layoutIfNeeded()
                }
            }).disposed(by: self.disposeBag)
        
        // 키보드가 올라올때 따라서 컨텐츠도 올림.
        RxKeyboard.instance.willShowVisibleHeight
            .map { [weak self] keyboardVisibleHeight -> CGFloat in
                guard let collectionView = self?.collectionView else { return 0.0}
                let remainContentsHeight = collectionView.frame.height - 64 - keyboardVisibleHeight - 46
                // 상단 사이즈 + 키보드사이즈 + 입력뷰  제외한 컨텐츠 영역
                
                // 스크롤 위치 + 컨텐츠 영역 + 키보드 높이가   컨텐츠 사이즈보다 작으면,  즉 스크롤 될 여지가 있으면.
                if collectionView.contentOffset.y + remainContentsHeight + keyboardVisibleHeight <= collectionView.contentSize.height {
                    return keyboardVisibleHeight // 키보드 만큼 올림.
                } else {
                    return collectionView.contentSize.height - remainContentsHeight // 남은 만큼 올림.
                }
            }.filter { $0 > 0 }.drive(onNext: { [weak self] differ in
                guard let `self` = self else { return }
                self.collectionView.contentOffset.y += differ
            }).disposed(by: self.disposeBag)
        
        sendButton.rx.tap.asObservable().throttle(0.2, scheduler: MainScheduler.instance)
            .withLatestFrom(self.commentTextField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .bind(to: loader.postComment)
            .disposed(by: disposeBag)
        
        loader.postDone.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.commentTextField.text = nil
            self.commentTextField.resignFirstResponder()
            let itemCount = self.collectionView.numberOfItems(inSection: 0)
            self.collectionView.scrollToItem(at: IndexPath(item: itemCount-1, section: 0), at: .bottom, animated: false)
        }).disposed(by: disposeBag)
        
    }
}

extension IssueDetailViewController {
    func createDatasource() -> DataSourceType {
        let datasource = DataSourceType(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
                assertionFailure()
                return CommentCell()
            }
            cell.update(data: item)
            return cell
        })
        datasource.configureSupplementaryView = { [weak self] datasource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard let `self` = self else { return UICollectionReusableView() }
            switch kind {
            case UICollectionElementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IssueDetailHeaderCell", for: indexPath) as? IssueDetailHeaderCell else {
                    assertionFailure()
                    return UICollectionViewCell()
                }
                self.header.onNext(header)
                self.loader.issueChangedObservable.bind(to: header.rx.issue).disposed(by: self.disposeBag)
                return header
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreCell ?? LoadMoreCell()
                self.loader.register(loadMoreCell: footerView)
                return footerView
            default:
                assertionFailure()
                return UICollectionReusableView()
            }
        }
        return datasource
    }
}

extension IssueDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = loader.item(at: indexPath) else { return CGSize.zero }
        estimateCell.update(data: data)
        let estimatedSize = CommentCell.cellSize(collectionView: collectionView, item: data, indexPath: indexPath)
        return estimatedSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if headerSize == CGSize.zero {
            headerSize = IssueDetailHeaderCell.headerSize(issue: issue, width: collectionView.frame.width)    
        }
        return headerSize
    }
}

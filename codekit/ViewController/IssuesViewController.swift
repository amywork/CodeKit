//
//  IssuesViewController.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
// App.api.repoIssues(owner: owner, repo: repo, page: 1) { (dataResponse) in


import UIKit
import Alamofire

protocol DataSourceRefreshable: class {
    associatedtype Item
    var datasource: [Item] { get set }
    var needRefreshDatasource: Bool { get set }
}

extension DataSourceRefreshable {
   
    func setNeedRefreshDatasource() {
        needRefreshDatasource = true
    }
   
    func refreshDatasourceIfNeeded() {
        if needRefreshDatasource {
            datasource = []
            needRefreshDatasource = false
        }
    }
}

class IssuesViewController: UIViewController, DataSourceRefreshable {
   
    /*DataSourceRefreshable*/
    var datasource: [Model.Issue] = []
    var needRefreshDatasource: Bool = false
    typealias Item = Model.Issue
    let refreshControl = UIRefreshControl()
    
    var page: Int = 1
    var canLoadMore: Bool = true
    var isLoading: Bool = false
    var loadMoreFooterView: LoadMoreFooterView?
    
    /*Property*/
    let owner: String = GlobalState.instance.owner
    let repo: String = GlobalState.instance.repo
    var dataSource: [Model.Issue] = []
    fileprivate let estimateCell: IssueCell = IssueCell.cellFromNib
    @IBOutlet weak var collectionView: UICollectionView!
    

    /*setup UI*/
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension IssuesViewController {
    
    /*UI*/
    func setup(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil) , forCellWithReuseIdentifier: "IssueCell")
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        load()
    }
    
    /*Data Load*/
    func load() {
        guard isLoading == false else { return }
        isLoading = true
        App.api.repoIssues(owner: owner, repo: repo, page: page) { [weak self] (dataResponse: DataResponse<[Model.Issue]>) in
            guard let weakSelf = self else { return }
            switch dataResponse.result {
            case .success(let items):
                weakSelf.isLoading = false
                weakSelf.dataLoaded(items: items)
            case .failure:
                break
            }
        }
    }
    
    func dataLoaded(items: [Model.Issue]) {
        refreshDatasourceIfNeeded()
        refreshControl.endRefreshing()
        page += 1
        if items.isEmpty {
            canLoadMore = false
            loadMoreFooterView?.loadDone()
        }
        dataSource.append(contentsOf: items)
        collectionView.reloadData()
    }
    
    @objc func refresh() {
        page = 1
        canLoadMore = true
        loadMoreFooterView?.load()
        setNeedRefreshDatasource()
        load()
    }
    
    func loadMore(indexPath: IndexPath) {
        guard indexPath.item == dataSource.count - 1 && !isLoading && canLoadMore else { return }
        load()
    }
    
}

/*UICollectionViewDataSource*/
extension IssuesViewController: UICollectionViewDataSource  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueCell", for: indexPath) as? IssueCell else { return IssueCell() }
        let data = dataSource[indexPath.row]
        cell.configureCell(data: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return UICollectionReusableView()
        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreFooterView", for: indexPath) as? LoadMoreFooterView ?? LoadMoreFooterView()
            return footer
        default:
            assert(false, "unexpected element kind")
            return UICollectionReusableView()
        }
    }
}

/*UICollectionViewDelegate, UICollectionViewFlowLayout*/
extension IssuesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = dataSource[indexPath.item]
        estimateCell.configureCell(data: data)
        let targetSize = CGSize(width: collectionView.frame.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        return estimatedSize
    }
    
}


// 일정 스크롤에서 더 많이 로드하는 것
extension IssuesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }
    
}

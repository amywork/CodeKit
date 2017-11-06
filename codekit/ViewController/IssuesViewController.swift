//
//  IssuesViewController.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.


import UIKit
import Alamofire

protocol DataSourceRefreshable: class {
    associatedtype Item
    var dataSource: [Item] { get set }
    var needRefreshDatasource: Bool { get set }
}

extension DataSourceRefreshable {
   
    func setNeedRefreshDatasource() {
        needRefreshDatasource = true
    }
   
    func refreshDatasourceIfNeeded() {
        if needRefreshDatasource {
            dataSource = []
            needRefreshDatasource = false
        }
    }
}

class IssuesViewController: UIViewController, DataSourceRefreshable {
   
    /*DataSourceRefreshable*/
    var needRefreshDatasource: Bool = false
    typealias Item = Model.Issue
    let refreshControl = UIRefreshControl()
    var page: Int = 1
    var canLoadMore: Bool = true
    var isLoading: Bool = false
    var loadMoreFooterView: LoadMoreFooterView?
    
    /*Property*/
    lazy var owner: String = { return GlobalState.instance.owner }()
    lazy var repo: String = { return GlobalState.instance.repo }()
    var dataSource: [Model.Issue] = []
    
    /*CollectionView*/
    fileprivate let estimateCell: IssueCell = IssueCell.cellFromNib
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    /*setup UI*/
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

extension IssuesViewController {
    
    @objc func refresh() {
        page = 1
        canLoadMore = true
        loadMoreFooterView?.load()
        setNeedRefreshDatasource()
        load()
    }
    
    /*UI*/
    func setup(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil) , forCellWithReuseIdentifier: "IssueCell")
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        load()
        loadMoreFooterView?.load()
    }
    
    /*Data Load - api.repoIssues*/
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
                weakSelf.isLoading = false
                break
            }
        }
    }
    
    /*Data Load - dataLoaded*/
    func dataLoaded(items: [Item]) {
        refreshDatasourceIfNeeded()
        
        page += 1
        if items.isEmpty {
            canLoadMore = false
            loadMoreFooterView?.loadDone()
        }
        
        refreshControl.endRefreshing()
        dataSource.append(contentsOf: items)
        collectionView.reloadData()
    }
    
    
    func loadMore(indexPath: IndexPath) {
        guard indexPath.item == dataSource.count - 10 && !isLoading && canLoadMore else { return }
        load()
    }


    func loadMore2() {
        guard !isLoading && canLoadMore else { return }
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
    
    //Reuse Supplementary View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreFooterView", for: indexPath) as? LoadMoreFooterView ?? LoadMoreFooterView()
            loadMoreFooterView = footerView
            return footerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
}

/*Cell Size*/
extension IssuesViewController: UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = dataSource[indexPath.item]
        estimateCell.configureCell(data: data)
        let targetSize = CGSize(width: collectionView.frame.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
        return estimatedSize
    }
    
}


/*will Display*/
extension IssuesViewController: UICollectionViewDelegate, UIScrollViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > collectionView.contentSize.height - (collectionView.frame.size.height) {
            loadMore2()
        }
    }


}

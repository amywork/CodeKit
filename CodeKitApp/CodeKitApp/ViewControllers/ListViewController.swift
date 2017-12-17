//
//  ListViewController.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
import Alamofire

protocol DatasourceRefreshable: class {
    associatedtype Item
    var dataSource: [Item] { get set }
    var needRefreshDataSource: Bool { get set }
}

extension DatasourceRefreshable {
   
    func setNeedRefreshDatasource() {
        needRefreshDataSource = true
    }
    
    func refreshDatasourceIfNeeded() {
        if needRefreshDataSource {
            dataSource = []
            needRefreshDataSource = false
        }
    }
}

class ListViewController<CellType: UICollectionViewCell & CellProtocol> : UIViewController, DatasourceRefreshable, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    lazy var owner: String = { return GlobalState.shared.owner }()
    lazy var repo: String = { return GlobalState.shared.repo }()
    
    typealias Item = CellType.Item
   
    var dataSource: [Item] = []
    var needRefreshDataSource: Bool = false
    
    var cellName: String { return "" }
    
    let refreshControl = UIRefreshControl()
    var page: Int = 1
    var canLoadMore: Bool = true
    var isLoading: Bool = false
    
    typealias ResponseHandler = (DataResponse<[Item]>) -> Void
    var api: ((Int, @escaping ResponseHandler) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var estimateCell: CellType = CellType.cellFromNib
    var loadMoreCell: LoadMoreFooterView?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        load()
        loadMoreCell?.load()
    }
    
    @objc func refresh() {
        page = 1
        canLoadMore = true
        loadMoreCell?.load()
        setNeedRefreshDatasource()
        load()
    }
    
    func load() {
        guard isLoading == false else { return }
        isLoading = true
        api?(page, { [weak self] (response: DataResponse<[Item]>) in
            guard let `self` = self else { return }
            switch response.result {
            case .success(let items):
                self.dataLoaded(items: items)
                self.isLoading = false
            case .failure:
                self.isLoading = false
                self.loadMoreCell?.loadDone()
                break
            }
        })
    }
    
    func dataLoaded(items: [Item]) {
        refreshDatasourceIfNeeded()
        page += 1
        if items.isEmpty {
            canLoadMore = false
            loadMoreCell?.loadDone()
        }
        loadMoreCell?.loadDone()
        refreshControl.endRefreshing()
        dataSource.append(contentsOf: items)
        collectionView.reloadData()
    }
    
    func loadMore(indexPath: IndexPath) {
        guard indexPath.item == dataSource.count - 10 && !isLoading && canLoadMore else { return }
        load()
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? CellType else { return UICollectionViewCell() }
        let item = dataSource[indexPath.item]
        cell.configureCell(data: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreFooterView", for: indexPath) as? LoadMoreFooterView ?? LoadMoreFooterView()
            loadMoreCell = footerView
            return footerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = dataSource[indexPath.item]
        estimateCell.configureCell(data: data)
        let targetSize = CGSize(width: collectionView.frame.size.width, height: 200)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        return estimatedSize
    }
    
    
}

//
//  ListViewController.swift
//  codekit
//
//  Created by Kimkeeyun on 12/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
import Alamofire

protocol DatasourceRefreshable: class {
    associatedtype Item
    var dataSource: [Item] { get set }
    var needRefreshDatasource: Bool { get set }
}

extension DatasourceRefreshable {
    func setNeedRefreshDatasource() {
        needRefreshDatasource = true
    }
    func refreshDataSourceIfNeeded() {
        if needRefreshDatasource {
            dataSource = []
            needRefreshDatasource = false
        }
    }
}

class ListViewController<CellType: UICollectionViewCell & CellProtocol>: UIViewController, DatasourceRefreshable, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    var dataSource: [CellType.Item] = []
    
    
    /*Property*/
    typealias Item = CellType.Item
    typealias ResponseHandler = (DataResponse<[Item]>) -> Void
    
    lazy var owner: String = { return GlobalState.instance.owner }()
    lazy var repo: String = { return GlobalState.instance.repo }()
    var api: ((Int, @escaping ResponseHandler) -> Void)?
    
    /*DataSourceRefreshable*/
    var needRefreshDatasource: Bool = false
    let refreshControl = UIRefreshControl()
    var page: Int = 1
    var canLoadMore: Bool = true
    var isLoading: Bool = false
    var loadMoreCell: LoadMoreFooterView?
    
    /*CollectionView*/
    fileprivate let estimateCell: CellType = CellType.cellFromNib
    @IBOutlet weak var collectionView: UICollectionView!
    var cellName: String { return "" }
    
    /*LifeCycle*/
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @objc func refresh() {
        page = 1
        canLoadMore = true
        loadMoreCell?.load()
        setNeedRefreshDatasource()
        load()
    }
    
    /*CollectionView*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? CellType else { return UICollectionViewCell() }
        let item = dataSource[indexPath.item]
        cell.configure(data: item)
        return cell
    }
    
    /*CollectionView -- SectionHeader & SectionFooter*/
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
    
    // Dynamic estimated cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = dataSource[indexPath.item]
        estimateCell.configure(data: data)
        let targetSize = CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        return estimatedSize
    }
    
    // Will Display -> Load more
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }
    
    // Header Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}



extension ListViewController {
  
    func setup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        load()
        loadMoreCell?.load()
    }
    
    func loadMore(indexPath: IndexPath) {
        guard indexPath.item == dataSource.count - 5 && !isLoading && canLoadMore else { return }
        load()
    }
    
    /*Data Load - api(page,handler)*/
    func load() {
        guard isLoading == false else {return }
        isLoading = true
      
        api?(page, { [weak self] (response: DataResponse<[Item]>) -> Void in
            guard let `self` = self else { return }
            switch response.result {
            case .success(let items):
                print("issues: \(items)")
                self.dataLoaded(items: items)
                self.isLoading = false
            case .failure:
                self.isLoading = false
                break
            }
        })
    }
    
    /*After Data Loaded*/
    func dataLoaded(items: [Item]) {
        refreshDataSourceIfNeeded()
        
        page += 1
        if items.isEmpty {
            canLoadMore = false
            loadMoreCell?.loadDone()
        }
        
        refreshControl.endRefreshing()
        dataSource.append(contentsOf: items)
        collectionView.reloadData()
    }
    
}

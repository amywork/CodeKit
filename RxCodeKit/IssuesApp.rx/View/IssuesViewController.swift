//
//  IssuesViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class IssuesViewController: UIViewController {

    typealias IssueSectionModel = SectionModel<Int, Model.Issue>
    typealias DataSourceType = RxCollectionViewSectionedReloadDataSource<IssueSectionModel>
    
    @IBOutlet var collectionView: UICollectionView!
    
    let estimateCell: IssueCell = IssueCell.cellFromNib
    let datasourceIn: BehaviorSubject<[Model.Issue]> = BehaviorSubject(value: [])
    let datasourceOut: BehaviorSubject<[IssueSectionModel]> = BehaviorSubject(value: [IssueSectionModel(model: 0, items: [])])
    let refreshControl = UIRefreshControl()
    
    var canLoadMore: Bool = true
    var loadMoreCell: LoadMoreCell?
    var disposeBag: DisposeBag = DisposeBag()
    var isLoading: Bool = false
    var apiCall: PublishSubject<Int> = PublishSubject()
    var page: Int = 1
    
    lazy var api: (Int) -> Observable<[Model.Issue]> = { () -> (Int) -> Observable<[Model.Issue]> in
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        return App.api.repoIssues(owner: owner, repo: repo)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        self.title = "\(owner)/\(repo)"
    }
    
}

extension IssuesViewController {
    func bind() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
         datasourceIn.asObservable().skip(1)
            .scan([], accumulator: { (old: [Model.Issue], new: [Model.Issue]) -> [Model.Issue] in
                return old + new
            }).map { (issues) -> [IssueSectionModel] in
                return [IssueSectionModel(model: 0, items: issues)]
            }.bind(to: datasourceOut).disposed(by: disposeBag)
        
        datasourceOut.asObservable()
            .do(onNext: { [weak self] issues in
                guard let `self` = self else { return }
                self.page += 1
                self.refreshControl.endRefreshing()
                if issues.isEmpty {
                    self.canLoadMore = false
                    self.loadMoreCell?.loadDone()
                }
            }).bind(to: collectionView.rx.items(dataSource: createDatasource()))
            .disposed(by: disposeBag)
        
        apiCall.flatMap {[unowned self ] page -> Observable<[Model.Issue]> in
            return self.api(page)
            }.do(onNext: { [weak self] (_) in
                self?.isLoading = false
                }, onError: { [weak self] _ in
                    self?.isLoading = false
            }).catchError({ (error) -> Observable<[Model.Issue]> in
                return Observable.just([])
            }).bind(to: datasourceIn)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] () in
                self?.refresh()
            }).disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell.asObservable()
            .subscribe(onNext: { [weak self] (_, indexPath: IndexPath) in
                self?.loadMore(indexPath: indexPath)
            }).disposed(by: disposeBag)
        
        loadData()
        
    }
}

extension IssuesViewController {
    
    func loadData() {
        guard isLoading == false else { return }
        isLoading = true
        apiCall.onNext(page)
    }
    
    func createDatasource() -> DataSourceType {
        let datasource = DataSourceType(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueCell", for: indexPath) as? IssueCell else {
                assertionFailure()
                return IssueCell()
            }
            cell.update(data: item)
            return cell
        })
        
        datasource.configureSupplementaryView = { [weak self] datasource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard let `self` = self else { return UICollectionReusableView() }
            switch kind {
            case UICollectionElementKindSectionHeader:
                assertionFailure()
                return UICollectionReusableView()
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreCell ?? LoadMoreCell()
                self.loadMoreCell = footerView
                return footerView
            default:
                assertionFailure()
                return UICollectionReusableView()
            }
        }
        return datasource
    }
    
    func refresh() {
        page = 1
        disposeBag = DisposeBag()
        canLoadMore = true
        loadMoreCell?.load()
        bind()
    }
    
    func loadMore(indexPath: IndexPath) {
        guard let value = try? datasourceOut.value() else { return }
        guard  indexPath.item == value[0].items.count - 1 && !isLoading && canLoadMore else { return }
        loadData()
    }
}

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let value = try? datasourceOut.value() else { return CGSize.zero }
        let items: [Model.Issue] = value[0].items
        let data = items[indexPath.item]
        estimateCell.update(data: data)
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        return estimatedSize
    }
}

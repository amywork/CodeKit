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

class IssuesViewController: UIViewController, SeguewayConstantable {
    typealias IssueSectionModel = SectionModel<Int, Model.Issue>
    typealias DataSourceType = RxCollectionViewSectionedReloadDataSource<IssueSectionModel>
    
    enum Constants: String {
        case pushToDetail
        case presentToCreateIssueSegue
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    let estimateCell: IssueCell = IssueCell.cellFromNib
    let refreshControl = UIRefreshControl()
    
    var loadMoreCell: LoadMoreCell?
    var disposeBag: DisposeBag = DisposeBag()
    var loader: IssuesLoader = IssuesLoader()
    var reloadIssueSubject: PublishSubject<Model.Issue> = PublishSubject()
    fileprivate var reloadSubject: PublishSubject<Void> = PublishSubject()
   
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueIdentifier: Constants = Constants(rawValue: segue.identifier ?? "") ?? .pushToDetail
        switch segueIdentifier {
        case .pushToDetail:
            guard let issue = sender as? Model.Issue else { return }
            guard let viewController = segue.destination as? IssueDetailViewController else { return }
            viewController.parentViewReload = reloadIssueSubject
            viewController.issue = issue
            break
        case .presentToCreateIssueSegue:
            guard let navigationController = segue.destination as? UINavigationController, let viewController = navigationController.topViewController as? CreateIssueViewController else { return }
            viewController.reloadSubject = reloadSubject
            // Create Issue 하고 refresh 하기 위함
            break
        }
    }
    
}

extension IssuesViewController {
    func bind() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        loader.bind()
        loader.datasource
            .bind(to: collectionView.rx.items(dataSource: createDatasource()))
            .disposed(by: disposeBag)
        loader.register(refreshControl: refreshControl)
        loader.registerLoadMore(collectionView: collectionView)
        
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            guard let issue = self.loader.item(at: indexPath) else { return }
            self.performSegue(withIdentifier: Constants.pushToDetail.rawValue, sender: issue)
        }).disposed(by: disposeBag)
        reloadIssueSubject
            .subscribe(onNext: { [weak self] (issue) in
                guard let `self` = self else { return }
                guard let indexPath = self.loader.index(of: issue) else { return }
                self.loader.replace(item: issue, indexPath: indexPath)
            }).disposed(by: disposeBag)
        reloadSubject.subscribe(onNext: { [weak self] _ in
            self?.loader.refresh()
        }).disposed(by: disposeBag)
    }
}

extension IssuesViewController {
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

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = loader.item(at: indexPath) else { return CGSize.zero }
        estimateCell.update(data: data)
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        return estimatedSize
    }
}



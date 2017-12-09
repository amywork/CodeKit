//
//  ReposViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReposViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: UIBarButtonItem!
    var repoSelectedSubject: PublishSubject<Repo>!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension ReposViewController {
    func bind() {
        GlobalState.instance.rx.repos.map{ (repos) -> [Repo] in
            return repos.repos
            }.bind(to: tableView.rx.items(cellIdentifier: "RepoCell", cellType: UITableViewCell.self)) { ( row,element, cell) in
                cell.textLabel?.text = "/\(element.owner)/\(element.repo)"
            }.disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { indexPath -> Repo in
                let repo = GlobalState.instance.repos.repos[indexPath.row]
                return repo
            }.do(onNext: {[weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).bind(to: repoSelectedSubject).disposed(by: disposeBag)
    }
}

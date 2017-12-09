//
//  RepoViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SeguewayConstantable {
    associatedtype Constants
}

class RepoViewController: UIViewController, SeguewayConstantable {
    enum Constants: String {
        case pushToIssueSegue
        case presentToReposSegue
        case none
    }
    
    @IBOutlet var ownerTextField: UITextField!
    @IBOutlet var repoTextField: UITextField!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    var repoSelectedSubject: PublishSubject<Repo> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalState.instance.rx.owner.bind(to: ownerTextField.rx.text).disposed(by: disposeBag)
        GlobalState.instance.rx.repo.bind(to: repoTextField.rx.text).disposed(by: disposeBag)
        bind()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier: Constants = Constants(rawValue: segue.identifier ?? "") ?? .none
        switch segueIdentifier {
        case .pushToIssueSegue:
            let owner = ownerTextField.text ?? ""
            let repo = repoTextField.text ?? ""
            GlobalState.instance.owner = owner
            GlobalState.instance.repo = repo
            GlobalState.instance.addRepo(owner: owner, repo: repo)
            break
        case .presentToReposSegue:
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let viewController = navigationController.topViewController as? ReposViewController else { return }
            viewController.repoSelectedSubject = repoSelectedSubject
            break
        case .none:
            break
        }
    }
}

extension RepoViewController {
    func bind() {
        logoutButton.rx.tap
            .subscribe(onNext: {
                GlobalState.instance.token = nil
            }).disposed(by: disposeBag)
        
        repoSelectedSubject
            .subscribe(onNext: { [weak self] repo in
                self?.performSegue(withIdentifier: Constants.pushToIssueSegue.rawValue, sender: repo)
            }).disposed(by: disposeBag)
    }
}

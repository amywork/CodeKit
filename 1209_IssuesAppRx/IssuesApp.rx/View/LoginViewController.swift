//
//  LoginViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, ViewControlelrFromStoryBoard {

    @IBOutlet var loginToGitHubButton: UIButton!
    @IBOutlet var loginToBitBucketButton: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension LoginViewController {
    func bind() {
        loginToGitHubButton.rx.tap.flatMap { _ -> Observable<Void> in
            App.api = GitHubAPI()
            GlobalState.instance.service = .github
            return App.api.getToken()
            }.subscribe(onError: { [weak self] error in
                guard let `self` = self else { return }
                let alert = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        loginToBitBucketButton.rx.tap.flatMap { _ -> Observable<Void> in
            App.api = BitBucketAPI()
            GlobalState.instance.service = .bitbucket
            return App.api.getToken()
            }.subscribe(onError: { [weak self] error in
                guard let `self` = self else { return }
                let alert = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        GlobalState.instance.rx.isLoggedIn.filter { $0 }.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)

    }
}

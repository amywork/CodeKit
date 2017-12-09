//
//  CreateIssueViewController.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 9..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateIssueViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var reloadSubject: PublishSubject<Void>?
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension CreateIssueViewController {
    func bind() {
        closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] () in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        doneButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Model.Issue> in
                let title = self?.titleTextField.text ?? ""
                let body = self?.bodyTextView.text ?? ""
                return App.api.postIssue(owner: GlobalState.instance.owner, repo: GlobalState.instance.repo, title: title, body: body)
            }.map { _ in
                return ()
            }.do(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                }, onError: { error in
                    
            }).bind(to: reloadSubject!).disposed(by: disposeBag)
    }
}

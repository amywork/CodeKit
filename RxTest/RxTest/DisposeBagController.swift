//
//  DisposeBagController.swift
//  RxTest
//
//  Created by 김기윤 on 02/12/2017.
//  Copyright © 2017 leonard. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DisposeBagController: UIViewController {
   
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var disposeBagBtn: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    var testDisposeBag: DisposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension DisposeBagController {
    
    func bind() {
        Observable<String>.create { (observer) -> Disposable in
            observer.onNext("HELLOWORLD")
            return Disposables.create {
                print("Disposed in Create")
            }
            }.subscribe(
                onNext: { text in
                    self.progressLabel.text = text
            }, onDisposed: {
                print("Disposed in subscribe")
            }).disposed(by: testDisposeBag)
        
        disposeBagBtn.rx.tap.asObservable().subscribe(
            onNext: { [weak self] _ in
            self?.testDisposeBag = DisposeBag()
        }).disposed(by: disposeBag)
    }
    
}

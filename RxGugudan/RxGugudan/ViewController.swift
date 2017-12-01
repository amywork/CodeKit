//
//  ViewController.swift
//  RxGugudan
//
//  Created by leonard on 2017. 11. 29..
//  Copyright © 2017년 rxswift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    var disposeBag: DisposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

}

extension ViewController {
    func bind() {
        textField.rx.text.orEmpty.asObservable()
            /*
             여기에 코드를 추가해보세요.
             */
            .bind(to: label.rx.text).disposed(by: disposeBag)
    }
}

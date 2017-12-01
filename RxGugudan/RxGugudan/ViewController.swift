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
            .map({ (str) -> String? in
                guard let number = Int(str) else { return nil }
                var result: String = ""
                for i in 1...9 {
                    result += "✏️ \(i) × \(number) = \(i*number) \n"
                }
                return result
            })
            .bind(to: label.rx.text).disposed(by: disposeBag)
    }
}




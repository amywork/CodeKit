//
//  ViewController.swift
//  RxTest
//
//  Created by leonard on 2017. 11. 27..
//  Copyright © 2017년 leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NinenineTableViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension NinenineTableViewController {
    func bind() {
        textField.rx.text.orEmpty.asObservable()
            .flatMap({(value) -> Observable<Int> in
                guard let result = Int(value) else { return Observable.empty() }
                return Observable.just(result)
            }).flatMap({(dan: Int) -> Observable<[String]> in
                Observable.from([1,2,3,4,5,6,7,8,9]).map({ (num) -> String in
                    return "\(dan) * \(num) = \(dan*num)"
                }).toArray()
            }).map({ steps -> String in
                return steps.reduce("", { (prev: String, next: String) -> String in
                    return prev + "\n" + next
                })
            })
            .bind(to: label.rx.text).disposed(by: disposeBag)
    }
}

// 나의 코드
extension NinenineTableViewController {
    func bind2() {
        textField.rx.text.orEmpty.asObservable()
            .map({ (str) -> String in
                guard let number = Int(str) else { return "" }
                var result: String = ""
                for i in 1...9 {
                    result += "✏️ \(i) × \(number) = \(i*number) \n"
                }
                return result
            })
            .bind(to: label.rx.text).disposed(by: disposeBag)
    }
}


// 수강생 코드
extension NinenineTableViewController {
    func bind3() {
        textField.rx.text.orEmpty.asObservable()
            .map({ (str) -> String in
                guard let number = Int(str) else { return "" }
                var result: String = ""
                let numArr = [1,2,3,4,5,6,7,8,9]
                result = numArr.map({ (num) -> String in
                    return "\(number) * \(num) = \(number*num)"
                }).reduce("", {$0 + "\n" + $1})
                return result
            })
            .bind(to: label.rx.text).disposed(by: disposeBag)
    }
}

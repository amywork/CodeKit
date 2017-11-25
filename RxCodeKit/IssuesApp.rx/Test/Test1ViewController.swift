//
//  Test1ViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 20..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Test1ViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        button.rx.tap.take(1).flatMap { [weak self] _ -> Observable<String?> in
            guard let `self` = self else { return Observable<String?>.never() }
            return self.textField.rx.text.asObservable()
            }.bind(onNext: { (value: String?) in
                
//                print("textField.rx.text.bind on Next: \(value)")
                
//                GlobalState.instance.rx.owner.accept(value)
                GlobalState.instance.owner = value ?? ""
//                GlobalState.instance.rx.ownerObserver.onNext(value)
            }).disposed(by:disposeBag)
            
            
//            .bind(to: GlobalState.instance.rx.owner ).disposed(by:disposeBag)
        
        
        GlobalState.instance.rx.owner.bind {[weak self] (value: String?) in
            guard let `self` = self else { return }
            
            self.label.rx.text.onNext(value)
        }.disposed(by: disposeBag)
        
//        GlobalState.instance.rx.owner.bind(to: label.rx.text).disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

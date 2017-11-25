//
//  Test2ViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 20..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Test2ViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    @IBOutlet var label: UILabel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textField.rx.text.bind(onNext: { (value: String?) in
                
                print("textField.rx.text.bind on Next: \(value)")
            
//                GlobalState.instance.rx.owner.accept(value)
//            GlobalState.instance.rx.ownerObserver.onNext(value)
            GlobalState.instance.owner = value ?? ""
            }).disposed(by:disposeBag)
            
            
            
//            .bind(to: GlobalState.instance.rx.owner ).disposed(by: disposeBag)
        GlobalState.instance.rx.owner.bind(to: label.rx.text).disposed(by: disposeBag)
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

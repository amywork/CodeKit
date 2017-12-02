//
//  UIAlertRx.swift
//  RxTest
//
//  Created by 김기윤 on 02/12/2017.
//  Copyright © 2017 leonard. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


extension Reactive where Base: UIAlertController {
    
    static func showAlertTo(_ viewController: UIViewController?, title: String, message: String) -> Observable<Void> {
        return Observable<Void>.create({ (observer) -> Disposable in
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: "YES",
                style: .cancel,
                handler: { (action) in
                    observer.onNext(())
                    observer.onCompleted()
            }))
            
            alert.addAction(UIAlertAction(
                title: "NO",
                style: .default))
            
            viewController?.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                
            }
        })
    }
}

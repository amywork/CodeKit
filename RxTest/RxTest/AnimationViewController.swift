//
//  AnimationViewController.swift
//  RxTest
//
//  Created by leonard on 2017. 11. 28..
//  Copyright © 2017년 leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AnimationViewController: UIViewController {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var box: UIView!
    
    var disposBag: DisposeBag = DisposeBag()
    
    var queue: [Observable<Void>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    let boxAnimationSubject: PublishSubject<Animation> = PublishSubject()
}

enum Animation {
    case left
    case right
    case up
    case down
    case composition(CGAffineTransform)
}

extension Animation {
    func transform(_ transform: CGAffineTransform) -> CGAffineTransform {
        switch self {
        case .left:
            return transform.translatedBy(x: -50, y: 0)
        case .right:
            return transform.translatedBy(x: 50, y: 0)
        case .up:
            return transform.translatedBy(x: 0, y: -50)
        case .down:
            return transform.translatedBy(x: 0, y: 50)
        case let .composition(t):
            return t.concatenating(transform)
        }
    }
}

extension Reactive where Base: UIView {
    func animation(_ animation: Animation) -> Observable<Void> {
        return Observable.create{ (observer) -> Disposable in
            
            UIView.animate(withDuration: 1, animations: {
                self.base.transform = animation.transform(self.base.transform)
            }, completion: { (result) in
                
                observer.onNext(())
                observer.onCompleted()
            })
            
            return Disposables.create {
                
            }
        }
    }
}

extension AnimationViewController {
    func bind() {
        
//        goButton.rx.tap.flatMap { [unowned self] _ in
//            Observable.concat([
//                self.box.rx.animation(.right),
//                self.box.rx.animation(.left),
//                self.box.rx.animation(.down),
//                self.box.rx.animation(.up)])
//            }.subscribe().disposed(by: disposBag)
        
                goButton.rx.tap
                    .flatMap {  [unowned self] _ in
                        return self.box.rx.animation(.up)
                    }.flatMap {  [unowned self] _ in
                        return self.box.rx.animation(.down)
                    }.flatMap {  [unowned self] _ in
                        return self.box.rx.animation(.left)
                    }.flatMap {  [unowned self] _ in
                        return self.box.rx.animation(.right)
                    }.subscribe().disposed(by: disposBag)
        
       
    }
}

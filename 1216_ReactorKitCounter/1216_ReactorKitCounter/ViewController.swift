//
//  ViewController.swift
//  1216_ReactorKitCounter
//
//  Created by 김기윤 on 16/12/2017.
//  Copyright © 2017 younari. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class ViewController: UIViewController, View {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = CounterViewReactor()
    }
    
    func bind(reactor: CounterViewReactor) {
        minusButton.rx.tap.map { CounterViewReactor.Action.decrease }
            .bind(to: reactor.action).disposed(by: disposeBag)
        
        plusButton.rx.tap.map { CounterViewReactor.Action.increase }
            .bind(to: reactor.action).disposed(by: disposeBag)
        
        reactor.state.map { $0.count }.map { "\($0)" }
            .bind(to: countLabel.rx.text).disposed(by: disposeBag)
        
        reactor.state.map { !$0.showIndicator }
            .distinctUntilChanged()
            .bind(to: activityIndicator.rx.isHidden).disposed(by: disposeBag)
        
        reactor.state.map { $0.showIndicator }
            .distinctUntilChanged()
            .bind(to: countLabel.rx.isHidden).disposed(by: disposeBag)
        
    }
    
}

// associated Type을 가질 경우 상속 못하는 final class
final class CounterViewReactor: Reactor {
    enum Action {
        case increase
        case decrease
    }
    
    enum Mutation {
        case increaseValue
        case decreaseValue
        case showIndicator
        case hideIndicator
    }
    
    struct State {
        var count: Int
        var showIndicator: Bool
    }
    
    let initialState: CounterViewReactor.State = State(count: 0, showIndicator: false)
    
    func mutate(action: CounterViewReactor.Action) ->
        Observable<CounterViewReactor.Mutation> {
            switch action {
            case .increase:
                return Observable.concat(
                    [Observable.just(Mutation.showIndicator),
                     Observable.just(Mutation.increaseValue)
                        .delay(0.5, scheduler: MainScheduler.instance),
                     Observable.just(Mutation.hideIndicator)])
                
            case .decrease:
                return Observable.concat(
                    [Observable.just(Mutation.showIndicator),
                     Observable.just(Mutation.decreaseValue)
                        .delay(0.5, scheduler: MainScheduler.instance),
                     Observable.just(Mutation.hideIndicator)])
            }
    }
    
    func reduce(state: CounterViewReactor.State,
                mutation: CounterViewReactor.Mutation) ->
        CounterViewReactor.State {
            switch mutation {
            case .increaseValue:
                return State(count: state.count + 1,
                             showIndicator: state.showIndicator)
            case .decreaseValue:
                return State(count: state.count - 1,
                             showIndicator: state.showIndicator)
            case .showIndicator:
                return State(count: state.count,
                             showIndicator: true)
            case .hideIndicator:
                return State(count: state.count,
                             showIndicator: false)
            }
    }
}

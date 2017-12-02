//
//  PlaygroundViewController.swift
//  For Testing RxMethod
//

import UIKit
import RxSwift
import RxCocoa

class PlaygroundViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var disposeBtn: UIButton!
    
    let subscribe: (Event<Int>) -> Void = { (event: Event) in
        switch event {
        case let .next(element):
            print("\(element)")
        case let .error(error):
            print(error.localizedDescription)
        case .completed:
            print("completed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // rxTransform()
        rxFiltering()
        // rxSubject()
        // rxCreate()
        // rxCombine()
        
        disposeBtn.rx.tap.asObservable().subscribe { [weak self] (_) in
            self?.disposeBag = DisposeBag()
        }
        
        // subscribe안에서 또 subscribe를 하지 않고,
        // flatmap을 통해서 subscribe은 1번만 일어나게 하자.
        /* Sample
         disposeBtn.rx.tap.asObservable().flatMap { () -> APICallObservable in
         return APICallObservable
         }.subscribe(onNext: { (value: String) in
         self.label.text = value }
         ).disposed(by: disposeBag)
         */
        
    }
    
}

extension PlaygroundViewController {
    
    
    func rxCreate() {
        /*
         create
         just
         from
         empty
         never
         error
         do
         repeatElement
         */
        
        print("\njust") // NEXT 이벤트를 하나 발생시키는 아이
        Observable<Int>.just(1).subscribe { (event: Event) in
            switch event {
            case let .next(element):
                print("\(element)")
            case let .error(error):
                print(error.localizedDescription)
            case .completed:
                print("completed")
            }
            }.disposed(by: disposeBag)
        
        
        print("\nOf")
        Observable.of(1,2,3,4,5).debug("of").subscribe(subscribe).disposed(by: disposeBag)
        
        print("\nFrom")
        Observable.from([1,2,3,4,5]).subscribe(subscribe).disposed(by: disposeBag)
        
        
        /*Create*/
        print("\nCreate")
        Observable<Int>.create { (observer: AnyObserver<Int>) -> Disposable in
            observer.on(Event.next(1))
            observer.on(Event.next(2))
            observer.on(Event.next(3))
            observer.onNext(4)
            observer.onError(NSError(domain: "RxError", code: 100000, userInfo: nil))
            observer.onCompleted() // Error 나면 Complete 실행 안되고 dispose 됨
            return Disposables.create {
                print("dispose")
            }
            }.subscribe(subscribe).disposed(by: disposeBag)
        
        
        /*Empty, Never*/
        print("\nEmpty")
        Observable<Int>.empty().debug("empty").subscribe(subscribe).disposed(by: disposeBag)
        
        print("\nNever")
        Observable<Int>.never().debug("never").subscribe(subscribe).disposed(by: disposeBag)
        
        
        /*Error*/
        print("\nError") // error 이벤트를 하나 발생시키는 아이
        Observable<Int>.error(NSError(domain: "RxDomain", code: 1118, userInfo: nil)).subscribe(subscribe).disposed(by: disposeBag)
        
        
        /*interval: 초마다 발생*/
        print("\nInterval")
        Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).take(10).subscribe(subscribe).disposed(by: disposeBag)
        
        /*
         print("\nRepeatElement")
         Observable<Int>.repeatElement(3).take(10).subscribe(subscribe).disposed(by: disposeBag)
         
         print("\nDoOn")
         Observable<Int>.from([1,2,3,4,5]).do(onNext: { (value) in
         print("do onNext: \(value)")
         }, onError: { (error) in
         print("do error: \(error)")
         }, onCompleted: {
         print("do completed")
         }, onSubscribe: {
         print("do subscribe")
         }, onSubscribed: {
         print("do subscribed")
         }, onDispose: {
         print("do disposed")
         }).debug("array").subscribe(onNext: {
         print($0)
         
         }).disposed(by: disposeBag)
         */
    }
    
    
    func rxSubject() {
        
        // observable과 observer가 한 몸인 경우
        print("\nPublish Subject")
        let publishSuject: PublishSubject<Int> = PublishSubject()
        publishSuject.subscribe(subscribe).disposed(by: disposeBag)
        publishSuject.on(.next(1))
        publishSuject.onNext(2)
        publishSuject.onNext(3)
        publishSuject.onCompleted()
        publishSuject.onNext(5) // 이 줄은 실행 안됨
        
        
        // 초기값까지 같이 observing
        // 들어있는 값을 꺼내서 볼 수 있음
        print("\nBehavior Subject")
        let behaviorSubject: BehaviorSubject<Int> = BehaviorSubject(value: 0)
        behaviorSubject.subscribe(subscribe).disposed(by: disposeBag)
        behaviorSubject.onNext(10)
        behaviorSubject.onNext(20)
        behaviorSubject.onNext(30)
        let value = (try? behaviorSubject.value()) ?? 0
        print("value: \(value)")
        
        
        // Behavior Subject가 필요한 경우:
        // 테이블뷰의 dataSource를 생각해보자.
        // 데이터가 바뀔 때마다 tableView.reload()
        let behaviorSubjectArray: BehaviorSubject<[Int]> = BehaviorSubject(value: [])
        behaviorSubjectArray.subscribe(onNext: { (array: [Int]) in
            print("behaviorSubjectArray: \(array)")
        }).disposed(by: disposeBag)
        behaviorSubjectArray.onNext([10, 20])
        behaviorSubjectArray.onNext([10, 20, 30])
        behaviorSubjectArray.onNext([10, 20, 30, 40])
        
        let arrayValue: [Int] = (try? behaviorSubjectArray.value()) ?? []
        // arrayValue[indexPath]
        print("Final Array Value: \(arrayValue)")
        
    }
    
    
    // API를 합쳐야 하거나, 유저 정보를 합쳐야 할 때
    func rxCombine() {
        /*merge, zip, combineLatest*/
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        
        /* merge
         Observable<Int>.merge([subject1, subject2]).debug("merge").subscribe(subscribe).disposed(by: disposeBag)
         */
        
        /* combineLatest
         Observable.combineLatest([subject1, subject2]) { (arr: [Int]) -> Int in
         return arr.reduce(0,+)
         }.subscribe(subscribe).disposed(by: disposeBag)
         */
        
        // zip : 2개씩 엮어서 꺼냄
        Observable<Int>.zip([subject1,subject2]) { (arr: [Int]) -> Int in
            return arr.reduce(0, +)
            }.debug("zip").subscribe(subscribe).disposed(by: disposeBag)
        
        subject1.onNext(1)
        subject2.onNext(2)
        subject1.onNext(3)
        subject2.onNext(4)
        subject1.onNext(5)
        subject2.onNext(6)
        
    }
    
    
    func rxTransform() {
        
        Observable<Int>.just(100).map { value -> String in
            return "value is \(value)"
            }.subscribe(onNext: { (value: String) in
                print(value)
            }).disposed(by: disposeBag)
        
        // observable을 바꾸고 싶을 때 flatMap
        Observable.just(3).flatMap { (value: Int) -> Observable<String> in
            return Observable.repeatElement("\(value) times").take(value)
            }.subscribe(onNext: { (value: String) in
                print(value) }
            ).disposed(by: disposeBag)
        
        let subject = PublishSubject<Void>()
        subject.flatMap { (_) -> Observable<Int> in
            return Observable<Int>.of(10,9,8,7)
            }.subscribe(onNext: { (value: Int) in
                print("value: \(value)")
            }).disposed(by: disposeBag)
        subject.onNext(())
        subject.onNext(())
        subject.onNext(())
        
    }
    
    func rxFiltering() {
        // filter, distinct, take, skip
        
        print("\n filter")
        Observable.from([1,2,3,4,5,6,7,8,9,10]).filter { (value) -> Bool in
            value % 2 == 0
            }.subscribe(subscribe).disposed(by: disposeBag)
        
        
        print("\n distinctUntilChanged")
        Observable.from([0,0,0,1,2,2]).distinctUntilChanged().subscribe(subscribe).disposed(by: disposeBag)
        
        // 스크롤을 하고 있을 때, 이동된 거리가 얼만큼 되었을 때 이벤트를 발생시킨다거나
        // 위치 트래킹하는데 3m 미만은 이벤트 발생을 방지시킨다거나...
        print("\n distinctUntilChanged")
        Observable.of(2,4,6,8,12,16,32,64).distinctUntilChanged { (lhs, rhs) -> Bool in
            return abs(lhs - rhs) > 0
            }.subscribe(subscribe).disposed(by: disposeBag)
        
        // 클릭 이벤트에 대하여 마구마구 발생했을 때 마지막꺼 하나만 가져오라는 등
        print("\n take(1)")
        Observable.from([9,8,7,6,5,4,3,2,1]).take(1).subscribe(subscribe).disposed(by: disposeBag)
        
        print("\n take(4)")
        Observable.from([9,8,7,6,5,4,3,2,1]).take(4).subscribe(subscribe).disposed(by: disposeBag)
        
        print("\n skip(1)")
        Observable.from([1,2,3,4,5,6,7,8,9]).skip(1).subscribe(subscribe).disposed(by: disposeBag)
        
        print("\n skip(4)")
        Observable.from([1,2,3,4,5,6,7,8,9]).skip(4).subscribe(subscribe).disposed(by: disposeBag)
        
    }
    
}








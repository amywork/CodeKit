//
//  GlobalState.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 19..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class GlobalState {
    static let instance: GlobalState = { () -> GlobalState in
        let state = GlobalState()
        state.rxInit()
        return state
    }()
    var disposeBag: DisposeBag = DisposeBag()
    
    enum ServiceType: String {
        case github
        case bitbucket
    }
    
    enum Constants: String {
        case tokenKey
        case refreshTokenKey
        case ownerKey
        case repoKey
        case reposKey
        case serviceTypeKey
    }
    
    var token: String? {
        get {
            let token = UserDefaults.standard.string(
                forKey: Constants.tokenKey.rawValue)
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.tokenKey.rawValue)
        }
    }
    var refreshToken: String? {
        get {
            let token = UserDefaults.standard.string(
                forKey: Constants.refreshTokenKey.rawValue)
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.refreshTokenKey.rawValue)
        }
    }
    
    var owner: String {
        get {
            let owner = UserDefaults.standard.string(forKey: Constants.ownerKey.rawValue) ?? ""
            return owner
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.ownerKey.rawValue)
        }
    }
    
    var repo: String {
        get {
            let owner = UserDefaults.standard.string(forKey: Constants.repoKey.rawValue) ?? ""
            return owner
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.repoKey.rawValue)
        }
    }
    
    var service: ServiceType {
        get {
            let serviceValue = UserDefaults.standard.string(forKey: Constants.serviceTypeKey.rawValue)
            return ServiceType.readValue(value: serviceValue)
        }
        set {
            UserDefaults.standard.set(newValue.writeValue, forKey: Constants.serviceTypeKey.rawValue)
        }
    }
    
    var repos: Repos {
        get {
            let repos = UserDefaults.standard.array(forKey: Constants.reposKey.rawValue) as? [[String: String]]
            return Repos.readValue(value: repos)
        }
        set {
            UserDefaults.standard.set(newValue.writeValue, forKey: Constants.reposKey.rawValue)
        }
    }
    
    func addRepo(owner: String, repo: String) {
        let repo = Repo(repo: repo, owner: owner)
        let repos = self.repos.add(repo: repo)
        UserDefaults.standard.set(repos.writeValue, forKey: Constants.reposKey.rawValue)
    }
}



extension GlobalState: ReactiveCompatible {
    func rxInit() {
        self.rx.serviceType.distinctUntilChanged().skip(1)
            .flatMap { _ -> Observable<Repos> in
                return Observable<Repos>.just(Repos(repos: []))
            }.bind { (repos: Repos) in
                self.repos = repos
            }.disposed(by: disposeBag)
    }
}

extension Reactive where Base: GlobalState {

    
    private func stateObservable<T: GlobalStatable>(key: String) -> Observable<T> {
        return UserDefaults.standard.rx
            .observe(T.WritableType.self, key)
            .map { (value: T.WritableType?) -> T in
                return T.readValue(value: value)
            }
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .debug(key)
            .share()
    }
    
    var token: Observable<String> {
        return self.stateObservable(key: Base.Constants.tokenKey.rawValue)
    }
    
    var refreshToken: Observable<String> {
        return self.stateObservable(key: Base.Constants.refreshTokenKey.rawValue)
    }
    
    var owner: Observable<String> {
        return self.stateObservable(key: Base.Constants.ownerKey.rawValue)
    }

    var repo: Observable<String> {
        return self.stateObservable(key: Base.Constants.repoKey.rawValue)
    }

    var serviceType: Observable<Base.ServiceType> {
        return self.stateObservable(key: Base.Constants.serviceTypeKey.rawValue)
    }

    var repos: Observable<Repos> {
        return self.stateObservable(key: Base.Constants.reposKey.rawValue)
    }

    var isLoggedIn: Observable<Bool> {
        return token.map { (token: String) -> Bool in
            return !token.isEmpty
        }
    }
}

extension GlobalState.ServiceType {
    public var api: API {
        switch self {
        case .github:
            return GitHubAPI()
        case .bitbucket:
            return BitBucketAPI()
        }
    }
}




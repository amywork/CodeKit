//
//  GlobalState.swift
//  codekit
//
//  Created by Kimkeeyun on 28/10/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation

final class GlobalState {
    
    static let instance = GlobalState()

    enum Constants: String {
        case tokenKey
        case refreshTokenKey
        case ownerKey
        case repoKey
        case reposKey
    }
    
    var token: String? {
        get {
            let token = UserDefaults.standard.string(
                forKey: Constants.tokenKey.rawValue)
            return token
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.tokenKey.rawValue)
        }
    }
    
    var refreshToken: String? {
        get {
            let token = UserDefaults.standard.string(
                forKey: Constants.refreshTokenKey.rawValue)
            return token
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.refreshTokenKey.rawValue)
        }
    }
    
    var owner: String {
        get {
            let owner = UserDefaults.standard.string(forKey: Constants.ownerKey.rawValue) ?? ""
            return owner
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.ownerKey.rawValue)
        }
    }
    
    var repo: String {
        get {
            let repo = UserDefaults.standard.string(forKey: Constants.repoKey.rawValue) ?? ""
            return repo
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.repoKey.rawValue)
        }
    }
    
    var isLoggedin: Bool {
        let isEmpty = token?.isEmpty ?? true
        return !isEmpty
    }
    
    
    var repos: [(owner: String, repo: String)] {
        let repoDics: [[String:String]] = UserDefaults.standard.array(forKey: Constants.reposKey.rawValue) as? [[String:String]] ?? []
        // dictionary -> tuple
        let repos = repoDics.map { (repoDic: [String:String]) -> (String,String) in
            let owner = repoDic["owner"] ?? ""
            let repo = repoDic["repo"] ?? ""
            return (owner, repo)
        }
        return repos
    }
    
    
    func addRepo(owner: String, repo: String){
        let dic = ["owner": owner, "repo": repo]
        var repos: [[String:String]] = UserDefaults.standard.array(forKey: Constants.reposKey.rawValue) as? [[String:String]] ?? []
        repos.append(dic)
        /* append 했을 때 중복이 발생할 수 있으므로
         arr -> set(집합)으로 바꿔서 중복 제거하고 arr로 바꿔서 다시 Userdefualt에 set
         */
        UserDefaults.standard.set(NSSet(array: repos).allObjects, forKey: Constants.reposKey.rawValue)
    }
    
}


//
//  GlobalState.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation

final class GlobalState {
    
    static var shared = GlobalState()
    
    enum Constants: String {
        case tokenKey
        case refreshTokenKey
        case ownerKey
        case repoKey
        case reposKey
    }
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.tokenKey.rawValue)
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.tokenKey.rawValue)
        }
    }
    
    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.refreshTokenKey.rawValue)
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.refreshTokenKey.rawValue)
        }
    }
    
    var owner: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.ownerKey.rawValue) ?? ""
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.ownerKey.rawValue)
        }
    }
    
    var repo: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.repoKey.rawValue) ?? ""
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.repoKey.rawValue)
        }
    }
    
    var isLoggined: Bool {
        let isEmpty = token?.isEmpty ?? true
        return !isEmpty
    }
    
    // MARK: - For bookmark repos
    var repos: [(owner: String, repo: String)] {
        let reposDics: [[String:String]] =
            UserDefaults.standard.array(forKey: Constants.reposKey.rawValue) as? [[String : String]] ?? []
        let repos = reposDics.map { (repoDic: [String:String]) -> (String,String) in
            let owner = repoDic["owner"] ?? ""
            let repo = repoDic["repo"] ?? ""
            return (owner,repo)
        }
        
        return repos
        
    }
    
    func addRepo(owner: String, repo: String) {
        let dic = ["owner": owner, "repo": repo]
        var repos: [[String:String]] =
            UserDefaults.standard.array(forKey: Constants.reposKey.rawValue) as? [[String : String]] ?? []
        repos.append(dic)
        
        UserDefaults.standard.set(NSSet(array: repos).allObjects, forKey: Constants.reposKey.rawValue)
    }
    
    
    
}

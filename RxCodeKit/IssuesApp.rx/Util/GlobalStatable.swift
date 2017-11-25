//
//  GlobalStatable.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation

protocol GlobalStatable: Equatable {
    associatedtype WritableType
    var writeValue: WritableType { get }
    static func readValue(value: WritableType?) -> Self
}

extension String: GlobalStatable {
    var writeValue: String {
        return self
    }
    static func readValue(value: String?) -> String {
        return value ?? ""
    }
}

extension GlobalState.ServiceType: GlobalStatable {
    var writeValue: String {
        return self.rawValue
    }
    
    static func readValue(value: String?) -> GlobalState.ServiceType {
        let serviceType = GlobalState.ServiceType(rawValue:  (value ?? "")) ?? GlobalState.ServiceType.github
        return serviceType
    }
}

extension Bool: GlobalStatable {
    var writeValue: Bool {
        return self
    }
    static func readValue(value: Bool?) -> Bool {
        return value ?? true
    }
}

struct Repo {
    var repo: String
    var owner: String
}

extension Repo: GlobalStatable, Hashable {
    static func ==(lhs: Repo, rhs: Repo) -> Bool {
        return lhs.repo == rhs.repo && lhs.owner == rhs.owner
    }
    
    var hashValue: Int {
        return repo.hashValue ^ owner.hashValue
    }
    
    var writeValue: [String: String] {
        return ["repo": repo, "owner": owner]
    }
    static func readValue(value: [String: String]?) -> Repo {
        let repo = value?["repo"] ?? ""
        let owner = value?["owner"] ?? ""
        return Repo(repo: repo, owner: owner)
    }
}

struct Repos {
    var repos: [Repo]
    func add(repo: Repo) -> Repos {
        let newRepos = Set<Repo>(repos + [repo]).map{$0}
        return Repos(repos: newRepos)
    }
}

extension Repos: GlobalStatable {
    
    typealias WritableType = [[String: String]]
    
    static func ==(lhs: Repos, rhs: Repos) -> Bool {
        guard lhs.repos.count == rhs.repos.count else { return false }
        return lhs.repos.elementsEqual(rhs.repos)
        
    }
    var writeValue: [[String : String]] {
        return self.repos.map {
            $0.writeValue
        }
    }
    
    static func readValue(value: [[String : String]]?) -> Repos {
        let repos =  value?.map { Repo.readValue(value: $0) } ?? []
        return  Repos(repos: repos)
    }
}

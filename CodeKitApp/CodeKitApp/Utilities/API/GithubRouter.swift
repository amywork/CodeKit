//
//  GithubRouter.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation
import Alamofire

enum GitHubRouter {
    case repoIssues(owner: String, repo: String, parameters: Parameters)
    case issueComment(owner: String, repo: String, number: Int, parameters: Parameters)
    case createComment(owner: String, repo: String, number: Int, parameters: Parameters)
    case editIssue(owner: String, repo: String, number: Int, parameters: Parameters)
    case createIssue(owner: String, repo: String, parameters: Parameters)
}

extension GitHubRouter: URLRequestConvertible {

    static let baseURLString: String = "https://api.github.com"
    
    static let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()

    
    var method: HTTPMethod {
        switch self {
        case .repoIssues,
             .issueComment:
            return .get
        case .createComment,
             .createIssue:
            return .post
        case .editIssue:
            return .patch
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        <#code#>
    }
    
    
    
}

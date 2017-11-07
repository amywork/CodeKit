//
//  GitHubRouter.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation
import Alamofire

/*--enum--*/
enum GitHubRouter {
    case repoIssues(owner: String, repo: String, parameters: Parameters)
}

extension GitHubRouter: URLRequestConvertible {
   
    /*--base URL String--*/
    static let baseURLString: String = "https://api.github.com"
   
    /*--Responsible for creating and managing Request objects, as well as their underlying NSURLSession.--*/
    static let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()

    /*--HTTP Method--*/
    var method: HTTPMethod {
        switch self {
        case .repoIssues:
            return .get
        }
    }
    
    /*--URL Path--*/
    var path: String {
        switch self {
        case let .repoIssues(owner, repo, _):
            return "/repos/\(owner)/\(repo)/issues"
        }
    }
    
    /*--URLRequest--*/
    func asURLRequest() throws -> URLRequest {
        let url = try GitHubRouter.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        if let token = GlobalState.instance.token, !token.isEmpty {
            //Sets a value for a header field.
            urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        /*--Encoding--*/
        switch self {
        case let .repoIssues(_, _, parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        return urlRequest
    }
    
}

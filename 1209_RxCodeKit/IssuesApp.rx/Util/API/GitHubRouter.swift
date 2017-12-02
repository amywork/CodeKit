//
//  GitHubRouter.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 23..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

enum GitHubRouter {
    case repoIssues(owner: String, repo: String)
}

extension GitHubRouter {
    static let baseURLString: String = "https://api.github.com"
    static var defaultHeaders: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        if let token = GlobalState.instance.token, !token.isEmpty {
            headers["Authorization"] = "token \(token)"
        }
        print("header: \(headers)")
        return headers
    }
    
    static let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        configuration.timeoutIntervalForResource = 30
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    var path: String {
        switch self {
        case let .repoIssues(owner, repo):
            return "/repos/\(owner)/\(repo)/issues"
        }
    }
    
    var url: URL {
        let url = (try? GitHubRouter.baseURLString.asURL())!
        return url.appendingPathComponent(path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .repoIssues:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .repoIssues:
            return URLEncoding.default
        }
    }
    
    func buildRequest(parameters: Parameters) -> Observable<Data> {
        return Observable.create { (anyObserver) -> Disposable in
            let request = GitHubRouter.manager.request(self.url, method: self.method, parameters: parameters, encoding: self.parameterEncoding, headers: GitHubRouter.defaultHeaders)
                .responseData(completionHandler: { (dataResponse: DataResponse<Data>) in
                    guard let response = dataResponse.response else {
                        anyObserver.onError(NSError(domain: "error", code: 1000, userInfo: nil))
                        return
                    }
                    print("status code: \(response.statusCode)")
                    
                    switch dataResponse.result {
                    case .success(let data) where response.statusCode/100 == 2 :
                        //우print("data: \(String(data: data, encoding: .utf8))")
                        anyObserver.onNext(data) // api 1콜만 하면되니까 onCompleted
                        anyObserver.onCompleted() // post api 에서 여러번 콜해야 할 경우
                    case .failure(let error):
                        print("error: \(error)")
                        anyObserver.onError(error)
                        
                    default:
                        let error = NSError(domain: "error", code: response.statusCode, userInfo: [:])
                        print("error: \(error)")
                        anyObserver.onError(error)
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

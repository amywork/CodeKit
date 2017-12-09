//
//  BitBicketRouter.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 23..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

enum BitBucketRouter {
    case repoIssues(owner: String, repo: String)
    case issueComment(owner: String, repo: String, number: Int)
    case postIssue(owner: String, repo: String)
    case postComment(owner: String, repo: String, number: Int)
    case editIssue(owner: String, repo: String, number: Int)
}

extension BitBucketRouter {
    static let baseURLString: String = "https://api.bitbucket.org"
    static var defaultHeaders: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        if let token = GlobalState.instance.token, !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
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
            return "/2.0/repositories/\(owner)/\(repo)/issues"
        case let .issueComment(owner, repo, number):
            return "/2.0/repositories/\(owner)/\(repo)/issues/\(number)/comments"
        case let .postComment(owner, repo, number):
            return "/2.0/repositories/\(owner)/\(repo)/issues/\(number)/comments"
        case let .postIssue(owner, repo):
            return "/2.0/repositories/\(owner)/\(repo)/issues"
        case let .editIssue(owner, repo, number):
            return "/repos/\(owner)/\(repo)/issues/\(number)"
        }
    }
    
    var url: URL {
        let url = (try? BitBucketRouter.baseURLString.asURL())!
        return url.appendingPathComponent(path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .repoIssues,
             .issueComment:
            return .get
        case .postComment,
             .postIssue:
            return .post
        case .editIssue:
            return .patch
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .repoIssues,
             .issueComment:
            return URLEncoding.default
        case .postComment,
             .postIssue,
             .editIssue:
            return JSONEncoding.default
        }
    }
    
    func buildRequest(parameters: Parameters) -> Observable<Data> {
        return Observable.create { (anyObserver) -> Disposable in
            let request = BitBucketRouter.manager.request(self.url, method: self.method, parameters: parameters, encoding: self.parameterEncoding, headers: BitBucketRouter.defaultHeaders)
                .responseData(completionHandler: { (dataResponse: DataResponse<Data>) in
                    guard let response = dataResponse.response else {
                        anyObserver.onError(NSError(domain: "error", code: 1000, userInfo: nil))
                        return
                    }
                    print("status code: \(response.statusCode)")
                    
                    switch dataResponse.result {
                    case .success(let data) where response.statusCode >= 200 && response.statusCode < 300 :
                        //                        print("data: \(String(data: data, encoding: .utf8))")
                        anyObserver.onNext(data)
                    case .failure(let error):
                        anyObserver.onError(error)
                        print("error: \(error)")
                    default:
                        let error = NSError(domain: "error", code: response.statusCode, userInfo: [:])
                        anyObserver.onError(error)
                        print("error: \(error)")
                    }
                })
            return Disposables.create {
                request.cancel()
            }
            }.retryWhen { erroObservable -> Observable<Void> in
                return erroObservable.flatMap({ (error: NSError) -> Observable<Void> in
                    if error.code == 401 {
                        return App.api.refreshToken()
                    } else {
                        return Observable.empty()
                    }
                })
        }
    }
}

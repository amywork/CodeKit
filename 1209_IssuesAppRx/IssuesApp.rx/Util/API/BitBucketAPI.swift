//
//  BitBucketAPI.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import OAuthSwift
import SwiftyJSON

struct BitBucketAPI: API {
    
    let bitbucketOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "vx2MD5uVaRyLgMxype",
        consumerSecret: "CA9cZxqWEgRDpZCCYy353WG763J8McWH",
        authorizeUrl:   "https://bitbucket.org/site/oauth2/authorize",
        accessTokenUrl: "https://bitbucket.org/site/oauth2/access_token",
        responseType:   "code"
    )
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
    
    func getToken() -> Observable<Void> {
        return Observable<Void>.create { (anyObserver) -> Disposable in
            self.bitbucketOAuth.authorize(
                withCallbackURL: URL(string: "ISSAPP://oauth-callback/bitbucket")!,
                scope: "issue:write", state:"state",
                success: { credential, _, _ in
                    GlobalState.instance.token = credential.oauthToken
                    GlobalState.instance.refreshToken = credential.oauthRefreshToken
                    App.api = BitBucketAPI()
                    anyObserver.onNext(())
                    anyObserver.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
                    anyObserver.onError(error)
            })
            return Disposables.create()
        }
    }
    func refreshToken() -> Observable<Void> {
        guard let refreshToken = GlobalState.instance.refreshToken else {
            return Observable.empty()
        }
        return Observable<Void>.create { anyObserver -> Disposable in
            self.bitbucketOAuth.renewAccessToken(
                withRefreshToken: refreshToken,
                success: { (credential, _, _) in
                    GlobalState.instance.token = credential.oauthToken
                    GlobalState.instance.refreshToken = credential.oauthRefreshToken
                    anyObserver.onNext(())
                    anyObserver.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
            })
            return Disposables.create()
        }
    }
    
    func repoIssues(owner: String, repo: String) -> (Int) -> Observable<[Model.Issue]> {
        return { page in
            let parameters: Parameters = ["page": page, "state": "all"]
            return BitBucketRouter.repoIssues(owner: owner, repo: repo).buildRequest(parameters: parameters)
                .map { data -> [Model.Issue] in
                    let json = (try? JSON(data: data)) ?? JSON()
                    let jsonIssues = json["values"]
                    let bitBucketJSONArray: [Any] = jsonIssues.arrayValue.map { (json: JSON) -> Any in
                        return json.githubIssueToBitbucket.object
                    }
                    let datas = (try? JSON(bitBucketJSONArray).rawData()) ?? Data()
                    guard let issues = try? self.decoder.decode([Model.Issue].self, from: datas) else { return [] }
                    return issues
                }.subscribeOn(MainScheduler.instance)
        }
    }
    func issueComment(owner: String, repo: String, number: Int) -> (Int) -> Observable<[Model.Comment]> {
        return { page in
            let parameters = ["page": page]
            
            return BitBucketRouter.issueComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters)
                .map { data -> [Model.Comment] in
                    let json = (try? JSON(data: data)) ?? JSON()
                    let jsonIssues = json["values"]
                    let bitBucketJSONArray: [Any] = jsonIssues.arrayValue.map { (json: JSON) -> Any in
                        return json.githubCommentToBitbucket.object
                    }
                    let datas = (try? JSON(bitBucketJSONArray).rawData()) ?? Data()
                    guard let issues = try? self.decoder.decode([Model.Comment].self, from: datas) else { return [] }
                    return issues
                }.subscribeOn(MainScheduler.instance)
        }
    }
    func toggleIssueState(owner: String, repo: String, number: Int, issue: Model.Issue) -> Observable<Model.Issue> {
        let nextState: Model.Issue.State = issue.state == Model.Issue.State.open ? .closed : .open
        let updatedIssue = issue.update(state: nextState)
        let parameters = (try? updatedIssue.asDictionary()) ?? Parameters()
        print("parameters: \(parameters)")
        return BitBucketRouter.editIssue(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters).flatMap { data -> Observable<Model.Issue> in
            guard let issue = try? self.decoder.decode(Model.Issue.self, from: data) else {
                return Observable.error(NSError(domain: "error", code: 1001, userInfo: nil))
            }
            return Observable.just(issue)
            }.subscribeOn(MainScheduler.instance)
    }
    
    func postComment(owner: String, repo: String, number: Int, comment: String) -> Observable<Model.Comment> {
        let parameters: Parameters = ["body": comment]
        return BitBucketRouter.postComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters)
            .flatMap { data -> Observable<Model.Comment> in
                guard let comment = try? self.decoder.decode(Model.Comment.self, from: data) else {
                    return Observable.error(NSError(domain: "error", code: 1001, userInfo: nil))
                }
                return Observable.just(comment)
            }.subscribeOn(MainScheduler.instance)
    }
    
    func postIssue(owner: String, repo: String, title: String, body: String) -> Observable<Model.Issue> {
        let parameters: Parameters = ["title": title, "content": ["raw":body]]
        return BitBucketRouter.postIssue(owner: owner, repo: repo).buildRequest(parameters: parameters).flatMap{ data -> Observable<Model.Issue> in
            let json = (try? JSON(data: data)) ?? JSON()
            let bitbucketIssueJSONData = (try? json.githubIssueToBitbucket.rawData()) ?? Data()
            guard let issue = try? self.decoder.decode(Model.Issue.self, from: bitbucketIssueJSONData) else {
                return Observable.error(NSError(domain: "error", code: 1001, userInfo: nil))
            }
            return Observable.just(issue)
            }.subscribeOn(MainScheduler.instance)
    }
}

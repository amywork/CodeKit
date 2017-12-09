//
//  GithubAPI.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift
import Alamofire

struct GitHubAPI: API {
    
    let githubOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "36c48adc3d1433fbd286",
        consumerSecret: "a911bfd178a79f25d14c858a1199cd76d9e92f3b",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
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
        return Observable<Void>.create { (observer) -> Disposable in
            self.githubOAuth.authorize(
                withCallbackURL: URL(string: "ISSAPP://oauth-callback/github")!,
                scope: "user,repo", state:"state",
                success: { credential, _, _ in
                    GlobalState.instance.token = credential.oauthToken
                    GlobalState.instance.refreshToken = credential.oauthRefreshToken
                    App.api = GitHubAPI()
                    observer.onNext(())
                    observer.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
                    observer.onError(error)
            })
            
            return Disposables.create()
        }
    }
    
    func refreshToken() -> Observable<Void> {
        guard let refreshToken = GlobalState.instance.refreshToken else {
            return Observable.empty()
        }
        return Observable<Void>.create { anyObserver -> Disposable in
            self.githubOAuth.renewAccessToken(
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
            return GitHubRouter.repoIssues(owner: owner, repo: repo).buildRequest(parameters: parameters).map { data in
                guard let issues = try? self.decoder.decode([Model.Issue].self, from: data) else { return [] }
                return issues
                }.subscribeOn(MainScheduler.instance)
        }
    }
    
    func issueComment(owner: String, repo: String, number: Int) -> (Int) -> Observable<[Model.Comment]> {
        return { page in
            let parameters = ["page": page]
            return GitHubRouter.issueComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters).map { data in
                guard let comments = try? self.decoder.decode([Model.Comment].self, from: data) else { return [] }
                return comments
                }.subscribeOn(MainScheduler.instance)
        }
    }
    
    func toggleIssueState(owner: String, repo: String, number: Int, issue: Model.Issue) -> Observable<Model.Issue> {
        let nextState: Model.Issue.State = issue.state == Model.Issue.State.open ? .closed : .open
        let updatedIssue = issue.update(state: nextState)
        let parameters = (try? updatedIssue.asDictionary()) ?? Parameters()
        print("parameters: \(parameters)")
        return GitHubRouter.editIssue(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters).flatMap { data -> Observable<Model.Issue> in
            guard let issue = try? self.decoder.decode(Model.Issue.self, from: data) else {
                return Observable.error(NSError(domain: "error", code: 1001, userInfo: nil))
            }
            return Observable.just(issue)
            }.subscribeOn(MainScheduler.instance)
    }
    
    func postComment(owner: String, repo: String, number: Int, comment: String) -> Observable<Model.Comment> {
        let parameters: Parameters = ["body": comment]
        return GitHubRouter.postComment(owner: owner, repo: repo, number: number).buildRequest(parameters: parameters)
            .flatMap { data -> Observable<Model.Comment> in
                guard let comment = try? self.decoder.decode(Model.Comment.self, from: data) else {
                    return Observable.error(NSError(domain: "error", code: 1001, userInfo: nil))
                }
                return Observable.just(comment)
            }.subscribeOn(MainScheduler.instance)
    }
    
    func postIssue(owner: String, repo: String, title: String, body: String) -> Observable<Model.Issue> {
        let parameters: Parameters = ["title":title, "body": body]
        return GitHubRouter.postIssue(owner: owner, repo: repo).buildRequest(parameters: parameters).flatMap{ data -> Observable<Model.Issue> in
            guard let issue = try? self.decoder.decode(Model.Issue.self, from: data) else {
                return Observable.error(NSError(domain: "error", code: 1001, userInfo: nil))
            }
            return Observable.just(issue)
            }.subscribeOn(MainScheduler.instance)
    }
    
}

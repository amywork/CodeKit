//
//  API.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//
//  AppScheme (CodeKit://)을 부르면 우리 앱을 열어준다.
//  Client ID : 9ad9115f8b0596c0587b
//  Client Secret ID : 6bbd79952ce40b83f42280896bb4120e0a4064fd
//  github.com/settings/applications/611648

import Foundation
import OAuthSwift
import SwiftyJSON
import Alamofire

protocol API {
    typealias IssueResponsesHandler = (DataResponse<[Model.Issue]>) -> Void
    typealias CommentResponsesHandler = (DataResponse<[Model.Comment]>) -> Void
    func getToken(handler: @escaping (() -> Void))
    func tokenRefresh(handler: @escaping (() -> Void))
    func repoIssues(owner: String, repo: String) -> (Int, @escaping IssueResponsesHandler) -> Void
    func issueComment(owner: String, repo: String, number: Int) -> (Int, @escaping CommentResponsesHandler) -> Void
    func createComment(owner: String, repo: String, number: Int, comment: String, completionHandler: @escaping (DataResponse<Model.Comment>) -> Void )
    func closeIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void)
    func openIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void)
    func createIssue(owner: String, repo: String, title: String, body: String, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void )
}


struct GitHubAPI: API {
    
    let oauth: OAuth2Swift = OAuth2Swift(
        consumerKey: "9ad9115f8b0596c0587b",
        consumerSecret: "6bbd79952ce40b83f42280896bb4120e0a4064fd",
        authorizeUrl: "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType: "code"
    )
    
    func getToken(handler: @escaping (() -> Void)) {
        oauth.authorize(withCallbackURL: "CodeKit://oauth-callback/github",
                        scope: "user, repo",
                        state: "state",
                        success: { (credential, _, _) in
                            let token = credential.oauthToken
                            let refreshToken = credential.oauthRefreshToken
                            print("token: \(token)")
                            GlobalState.instance.token = token
                            GlobalState.instance.refreshToken = refreshToken
                            handler()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tokenRefresh(handler: @escaping (() -> Void)) {
        guard let refreshToken =
            GlobalState.instance.refreshToken else { return }
        oauth.renewAccessToken(withRefreshToken: refreshToken, success: { (credential, _, _) in
            let token = credential.oauthToken
            let refreshToken = credential.oauthRefreshToken
            GlobalState.instance.token = token
            GlobalState.instance.refreshToken = refreshToken
            handler()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func repoIssues(owner: String, repo: String) -> (Int, @escaping IssueResponsesHandler) -> Void {
        return { (page, handler) in
            let parameters: Parameters = ["page": page, "state": "all"]
            GitHubRouter.manager.request(GitHubRouter.repoIssues(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({ (json: JSON) -> [Model.Issue] in
                    return json.arrayValue.map {
                        Model.Issue(json: $0)
                    }
                })
                handler(result)
            }
        }
    }

    func issueComment(owner: String, repo: String, number: Int) -> (Int, @escaping CommentResponsesHandler) -> Void {
        return { (page, handler) in
            let parameters: Parameters = ["page": page]
            GitHubRouter.manager.request(GitHubRouter.issueComment(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON{ (dataResponse: DataResponse<JSON>) in
                let result = dataResponse.map({  (json: JSON) -> [Model.Comment] in
                    return json.arrayValue.map{
                        Model.Comment(json: $0)
                    }
                })
                handler(result)
            }
        }
    }
    
    func createComment(owner: String, repo: String, number: Int, comment: String, completionHandler: @escaping (DataResponse<Model.Comment>) -> Void ) {
        let parameters: Parameters = ["body": comment]
        GitHubRouter.manager.request(GitHubRouter.createComment(owner: owner, repo: repo, number: number, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Comment in
                Model.Comment(json: json)
            })
            completionHandler(result)
        }
    }
    
    func closeIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.closed.rawValue
        GitHubRouter.manager.request(GitHubRouter.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }
    
    func openIssue(owner: String, repo: String, number: Int, issue: Model.Issue, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void) {
        var dict = issue.toDict
        dict["state"] = Model.Issue.State.open.rawValue
        GitHubRouter.manager.request(GitHubRouter.editIssue(owner: owner, repo: repo, number: number, parameters: dict)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }
    
    func createIssue(owner: String, repo: String, title: String, body: String, completionHandler: @escaping (DataResponse<Model.Issue>) -> Void ) {
        let parameters: Parameters = ["title": title, "body": body]
        GitHubRouter.manager.request(GitHubRouter.createIssue(owner: owner, repo: repo, parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result = dataResponse.map({ (json: JSON) -> Model.Issue in
                Model.Issue(json: json)
            })
            completionHandler(result)
        }
    }

}



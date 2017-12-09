//
//  API.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift

protocol API {
    func getToken() -> Observable<Void>
    func refreshToken() -> Observable<Void>
    func repoIssues(owner: String, repo: String) -> (Int) -> Observable<[Model.Issue]>
    func issueComment(owner: String, repo: String, number: Int) -> (Int) -> Observable<[Model.Comment]>
    func toggleIssueState(owner: String, repo: String, number: Int, issue: Model.Issue) -> Observable<Model.Issue>
    func postComment(owner: String, repo: String, number: Int, comment: String) -> Observable<Model.Comment>
    func postIssue(owner: String, repo: String, title: String, body: String) -> Observable<Model.Issue>
}

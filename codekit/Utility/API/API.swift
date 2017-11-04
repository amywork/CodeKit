//
//  API.swift
//  codekit
//
//  Created by Kimkeeyun on 28/10/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//  AppScheme (여기서는 CodeKit://)을 부르면 우리 앱을 열어준다.


import Foundation

protocol API {
    func getToken(handler: @escaping(() -> Void))
    func tokenRefresh(handler: @escaping(() -> Void))
    func repoIssues(owner: String, repo: String, page: Int, handler: @escaping IssuesResponseHandler)
}

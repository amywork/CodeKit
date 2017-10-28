//
//  API.swift
//  codekit
//
//  Created by Kimkeeyun on 28/10/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation
import OAuthSwift

protocol API {
    func getToken(handler: @escaping(() -> Void))
    func tokenRefresh(handler: @escaping(() -> Void))
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
            print("token: \(token)")
            GlobalState.instance.token = token
            GlobalState.instance.refreshToken = refreshToken
            handler()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}


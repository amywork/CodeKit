//
//  BitBucketAPI.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift

struct BitbucketAPI: API {
    
    let bitbucketOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "vx2MD5uVaRyLgMxype",
        consumerSecret: "CA9cZxqWEgRDpZCCYy353WG763J8McWH",
        authorizeUrl:   "https://bitbucket.org/site/oauth2/authorize",
        accessTokenUrl: "https://bitbucket.org/site/oauth2/access_token",
        responseType:   "code"
    )
    
    func getToken() -> Observable<Void> {
        return Observable<Void>.create { (anyObserver) -> Disposable in
            self.bitbucketOAuth.authorize(
                withCallbackURL: URL(string: "ISSAPP://oauth-callback/bitbucket")!,
                scope: "issue:write", state:"state",
                success: { credential, _, _ in
                    GlobalState.instance.token = credential.oauthToken
                    GlobalState.instance.refreshToken = credential.oauthRefreshToken
                    App.api = BitbucketAPI()
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
        return { page in return Observable.empty() }
    }
}

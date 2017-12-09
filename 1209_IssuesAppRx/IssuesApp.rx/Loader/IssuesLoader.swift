//
//  IssuesLoader.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 4..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class IssuesLoader: Loader<Model.Issue> {
    override init() {
        super.init()
        api = { () -> (Int) -> Observable<[Model.Issue]> in
            let owner = GlobalState.instance.owner
            let repo = GlobalState.instance.repo
            return App.api.repoIssues(owner: owner, repo: repo)
        }()
    }
}


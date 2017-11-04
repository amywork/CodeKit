//
//  IssuesViewController.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
import Alamofire

class IssuesViewController: UIViewController {

    let owner: String = GlobalState.instance.owner
    let repo: String = GlobalState.instance.repo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.api.repoIssues(owner: owner, repo: repo, page: 1) { (dataResponse) in
            print(dataResponse.value)
        }
    }


}

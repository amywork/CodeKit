//
//  App.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation

struct App {
    static var api: API = {
        return GlobalState.instance.service.api
    }()
}

//
//  Optional+Extension.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 19..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Equatable {
    static func distinct(old: Wrapped?, new: Wrapped?) -> Bool {
        switch (old, new) {
        case (nil, nil):
            return false
        case (nil, .some):
            return false
        case (.some, nil):
            return false
        case (.some(let old), .some(let new)):
            return old == new
        }
    }
}

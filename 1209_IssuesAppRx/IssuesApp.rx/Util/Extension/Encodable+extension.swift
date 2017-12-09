//
//  Encodable+extension.swift
//  GithubIssues.Rx
//
//  Created by Leonard on 2017. 10. 15..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

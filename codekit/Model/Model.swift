//
//  Model.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//  init(json: JSON)
//  https://developer.github.com/v3/issues/#list-issues-for-a-repository

import Foundation
import SwiftyJSON

struct Model {
    
}

// User Model
extension Model {
    
    struct User {
        let id: String
        let login: String
        let avatarURL: URL?
        init(json: JSON) {
            id = json["id"].stringValue
            login = json["login"].stringValue
            avatarURL = URL(string: json["avatar_url"].stringValue)
        }
    }

}

// Issue Model
extension Model {
    
    struct Issue {
        let id: Int
        let number: Int
        let title: String
        let user: Model.User
        let comments: Int
        let body: String
        let createdAt: Date?
        let updatedAt: Date?
        let closedAt: Date?
        let state: State
        
        init(json: JSON) {
            print("issue json: \(json)")
            id = json["id"].intValue
            number = json["number"].intValue
            title = json["title"].stringValue
            user = Model.User(json: json["user"])
            state = State(rawValue: json["state"].stringValue) ?? .open
            comments = json["comments"].intValue
            body = json["body"].stringValue
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            createdAt = format.date(from: json["created_at"].stringValue)
            updatedAt = format.date(from: json["updated_at"].stringValue)
            closedAt = format.date(from: json["closed_at"].stringValue)
        }
    }
    
}

// Issue -> State
extension Model.Issue {
    
    enum State: String {
        case open
        case closed
    }
    
}

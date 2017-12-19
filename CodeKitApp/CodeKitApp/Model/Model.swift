//
//  Model.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Model { }

extension Model {
    
    struct Issue {
        let id: Int
        let number: Int
        let title: String
        let body: String
        let comments: Int
        let user: Model.User
        let state: State
        let createdAt: Date?
        let updatedAt: Date?
        let closedAt: Date?
        
        init(json: JSON) {
            id = json["id"].intValue
            number = json["number"].intValue
            title = json["title"].stringValue
            body = json["body"].stringValue
            comments = json["comments"].intValue
            user = Model.User(json: json["user"])
            state = State(rawValue: json["state"].stringValue) ?? .open
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            createdAt = formatter.date(from: json["created_at"].stringValue)
            updatedAt = formatter.date(from: json["updated_at"].stringValue)
            closedAt = formatter.date(from: json["closed_at"].stringValue)
        }
        
    }
    
}

extension Model.Issue {
 
    enum State : String {
        case open
        case closed
    }
    
}



extension Model.Issue : Equatable {
  
    static func ==(lhs: Model.Issue, rhs: Model.Issue) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension Model.Issue {
    
    var toDictionary: [String:Any] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        var dict: [String : Any] = [
            "id": id,
            "number": number,
            "title": title,
            "comments": comments,
            "body": body,
            "state": state.rawValue,
            "user": [
                "id": user.id,
                "login": user.login,
                "acatar_url": (user.avatarURL?.absoluteString ?? "")]
        ]
        if let createdAt = createdAt {
            dict["createdAt"] = formatter.string(from: createdAt)
        }
        if let updatedAt = updatedAt {
            dict["updatedAt"] = formatter.string(from: updatedAt)
        }
        if let closedAt = closedAt {
            dict["closedAt"] = formatter.string(from: closedAt)
        }
        return dict
    }
    
}

extension Model.Issue.State {
    
    var color: UIColor {
        switch self {
        case .open:
            return UIColor(red: 131/255, green: 189/255, blue: 71/255, alpha: 1)
        case .closed:
            return UIColor(red: 71/255, green: 71/255, blue: 71/255, alpha: 1)
        }
    }
}

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

extension Model {
    
    struct Comment {
        let id: Int
        let user: Model.User
        let body: String
        let createdAt: Date?
        let updatedAt: Date?
        public init(json: JSON) {
            id = json["id"].intValue
            user = Model.User(json: json["user"])
            body = json["body"].stringValue
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            createdAt = formatter.date(from: json["created_at"].stringValue)
            updatedAt = formatter.date(from: json["updated_at"].stringValue)
        }
    }
    
}

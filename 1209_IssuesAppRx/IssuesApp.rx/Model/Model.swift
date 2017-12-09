//
//  Model.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 23..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Model {
    struct Issue: Codable, ListableModel, Equatable {
        let id: Int
        let number: Int
        let title: String
        let user: Model.User
        let state: State
        let comments: Int
        let body: String
        let createdAt: Date?
        let updatedAt: Date?
        let closedAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case id
            case user
            case body
            case number
            case title
            case comments
            case state
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case closedAt = "closed_at"
        }
        
        static func ==(lhs: Model.Issue, rhs: Model.Issue) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

protocol ListableModel {
    
}

extension Model {
    
}

extension Model.Issue {
    enum State: String, Codable {
        case open
        case closed
    }
    
    func update(state: Model.Issue.State) -> Model.Issue {
        return Model.Issue(id: self.id, number: self.number, title: self.title, user: self.user, state: state, comments: self.comments, body: self.body, createdAt: self.createdAt, updatedAt: self.updatedAt, closedAt: self.closedAt)
    }
}

extension Model.Issue.State {
    var color: UIColor {
        switch  self {
        case .open:
            return UIColor(red: 131/255, green: 189/255, blue: 71/255, alpha: 1)
        case .closed:
            return UIColor(red: 176/255, green: 65/255, blue: 32/255, alpha: 1)
        }
    }
}

extension Model {
    struct User: Codable {
        var id: String
        var login: String
        var avatarURL: URL?
        
        enum CodingKeys: String, CodingKey {
            case id
            case login
            case avatarURL = "avatar_url"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            login = try values.decode(String.self, forKey: .login)
            let avatarURLString = try values.decode(String.self, forKey: .avatarURL)
            if let url = URL(string: avatarURLString) {
                avatarURL = url
            }
            do {
                let idValue = try values.decode(Int.self, forKey: .id)
                id = "\(idValue)"
            } catch {
                id = try values.decode(String.self, forKey: .id)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(login, forKey: .login)
            try container.encode(avatarURL, forKey: .avatarURL)
        }
    }
}

extension Model {
    public struct Comment: Codable, ListableModel, Equatable {
        let id: Int
        let user: Model.User
        let body: String
        let createdAt: Date?
        let updatedAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case id
            case user
            case body
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
        
        static func ==(lhs: Model.Comment, rhs: Model.Comment) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

extension JSON {
    /*
     id -> id
     number -> id
     title -> title
     comments ->
     body -> [content][raw]
     createdAt -> created_on
     closedAt ->  state, new -> open, closed -> closed
     */
    var githubIssueToBitbucket: JSON {
        var json = JSON()
        json["id"] = self["id"]
        json["number"] = self["id"]
        json["title"] = self["title"]
        json["body"] = self["content"]["raw"]
        json["user"] = self["reporter"].githubUserToBitbucket
        json["comments"] = JSON(0)
        switch self["state"].stringValue {
        case "new":
            json["state"].string = "open"
        case "closed":
            json["state"].string = "closed"
        default:
            json["state"].string = "open"
        }
        let created_at = (self["created_on"].stringValue.components(separatedBy: ".").first ?? "")+"Z"
        json["created_at"].string = created_at
        return json
    }
    /*id -> uuid
     login -> username
     avatar_url -> ["links"]["avatar"]["href"]*/
    var githubUserToBitbucket: JSON {
        var json = JSON()
        json["id"] = self["uuid"]
        json["login"] = self["username"]
        json["avatar_url"] = self["links"]["avatar"]["href"]
        return json
    }
    /*
     id -> id
     user -> user.git
     body -> ["content"]["raw"]
     createdAt -> created_on
     updatedAt -> updated_on
     */
    var githubCommentToBitbucket: JSON {
        var json = JSON()
        json["id"] = self["id"]
        json["user"] = self["user"].githubUserToBitbucket
        json["body"] = self["content"]["raw"]
        let createdAt = (self["created_on"].stringValue.components(separatedBy: ".").first ?? "")+"Z"
        json["created_at"].string = createdAt
        if let upatedString = self["updated_on"].string {
            let updatedAt = (upatedString.components(separatedBy: ".").first ?? "")+"Z"
            json["updated_at"].string = updatedAt
        }
        
        return json
    }
}

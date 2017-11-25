//: Playground - noun: a place where people can play

import UIKit

let userData = """
{
    "login": "octocat",
    "id": 1,
    "avatar_url": "https://github.com/images/error/octocat_happy.gif",
    "created_at": "2011-04-10T20:09:31Z",
    "gravatar_id": "",
    "url": "https://api.github.com/users/octocat",
    "html_url": "https://github.com/octocat",
    "followers_url": "https://api.github.com/users/octocat/followers",
    "following_url": "https://api.github.com/users/octocat/following{/other_user}",
    "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
    "organizations_url": "https://api.github.com/users/octocat/orgs",
    "repos_url": "https://api.github.com/users/octocat/repos",
    "events_url": "https://api.github.com/users/octocat/events{/privacy}",
    "received_events_url": "https://api.github.com/users/octocat/received_events",
    "type": "User",
    "site_admin": false
}
""".data(using: .utf8)!
//
//struct User: Codable {
//    var id: Int
//    var login: String
//    var avatarURL: String
//    let createdAt: Date?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case login
//        case avatarURL = "avatar_url"
//        case createdAt = "created_at"
//    }
//}

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
        // id가 Int인 경우와, String인 경우를 분기
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


let decoder = JSONDecoder()
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
// 날짜를 parsing 하고 싶을 때
decoder.dateDecodingStrategy = .formatted(formatter)

let user = try? decoder.decode(User.self, from: userData)
user?.id
user?.login
user?.avatarURL
//user?.createdAt


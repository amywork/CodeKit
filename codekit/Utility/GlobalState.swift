//
//  GlobalState.swift
//  codekit
//
//  Created by Kimkeeyun on 28/10/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation

final class GlobalState {
    
    static let instance = GlobalState()
    
    enum Constants: String {
        case tokenKey
        case refreshTokenKey
    }
    
    var token: String? {
        get {
            let token = UserDefaults.standard.string(
                forKey: Constants.tokenKey.rawValue)
            return token
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.tokenKey.rawValue)
        }
    }
    
    var refreshToken: String? {
        get {
            let token = UserDefaults.standard.string(
                forKey: Constants.refreshTokenKey.rawValue)
            return token
        }set {
            UserDefaults.standard.set(newValue, forKey: Constants.refreshTokenKey.rawValue)
        }
    }
    
}


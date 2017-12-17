//
//  Extensions.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

enum BackendError: Error {
    case network(error: Error)
    case dataSerialization(reason: String)
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
    case xmlSerialization(error: Error)
}

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


extension DataRequest {
  
    //@discardableResult
    public func responseSwiftyJSON(_ completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<JSON> { request, response, data, error in
            guard error == nil else {
                DataRequest.errorMessage(response, error: error, data: data)
                return .failure(error!)
            }
            let result = DataRequest
                .jsonResponseSerializer(options: .allowFragments)
                .serializeResponse(request, response, data, error)
            switch result {
            case .success(let value):
                if let _ = response {
                    return .success(JSON(value))
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = BackendError.objectSerialization(reason: failureReason)
                    DataRequest.errorMessage(response, error: error, data: data)
                    return .failure(error)
                }
            case .failure(let error):
                DataRequest.errorMessage(response, error: error, data: data)
                return .failure(error)
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    static func errorMessage(_ response: HTTPURLResponse?, error: Error?, data: Data?) {
        debugPrint("status: \(response?.statusCode ?? -1), error message:\(error.debugDescription)")
    }
}


extension UIColor {
    
    func toImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(self.cgColor)
            context.fill(rect)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return image
            }
        }
        return UIImage()
    }
    
}

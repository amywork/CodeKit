//
//  UIColor+Extension.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 5..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

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

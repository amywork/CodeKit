//
//  ViewControlelrFromStoryBoard.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

protocol ViewControlelrFromStoryBoard: class {
    
}

extension ViewControlelrFromStoryBoard where Self: UIViewController {
    static var viewController: Self {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: Self.self)) as? Self else { return Self() }
        return viewController
    }
}

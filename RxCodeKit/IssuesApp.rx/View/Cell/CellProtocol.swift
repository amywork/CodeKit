//
//  CellProtocol.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 23..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

protocol CellProtocol: class {
    associatedtype Item
    func update(data: Item)
    static var cellFromNib: Self { get }
}

extension CellProtocol where Self: UICollectionViewCell {
    static var cellFromNib: Self {
        guard let cell = Bundle.main.loadNibNamed(String(describing: Self.self) , owner: nil, options: nil)?.first as? Self else {
            return Self()
        }
        return cell
    }
}

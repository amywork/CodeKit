//
//  IssueCell.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 17/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit

protocol CellProtocol {
    associatedtype Item
    func configureCell(data: Item)
    static var cellFromNib: Self { get }
}

final class IssueCell: UICollectionViewCell {
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var commentCountButton: UIButton!
}


extension IssueCell: CellProtocol {
    
    typealias Item = Model.Issue
    
    static var cellFromNib: IssueCell {
        guard let cell = Bundle.main.loadNibNamed("IssueCell", owner: nil, options: nil)?.first as? IssueCell else { return IssueCell() }
        return cell
    }
    
    func configureCell(data issue: Model.Issue) {
        titleLabel.text = issue.title
        
        let createdAt: String = issue.createdAt?.string(dateFormat: "dd MMM yyyy") ?? "-"
        contentsLabel.text = "#\(issue.number) \(issue.state.rawValue) on \(createdAt) by \(issue.user.login)"
        
        stateButton.isSelected = issue.state == .closed
        stateButton.setTitle(Model.Issue.State.open.rawValue, for: .normal)
        stateButton.setBackgroundImage(Model.Issue.State.open.color.toImage(), for: .normal)
        stateButton.setTitle(Model.Issue.State.closed.rawValue, for: .selected)
        stateButton.setBackgroundImage(Model.Issue.State.closed.color.toImage(), for: .selected)
        
        
        commentCountButton.setTitle("💬\(issue.comments)", for: .normal)
        let commentCountHidden: Bool = issue.comments == 0
        commentCountButton.alpha = commentCountHidden ? 0 : 1
        
    }

}

extension Date {
    func string(dateFormat: String, locale: String = "en-US") -> String {
        let format = DateFormatter()
        format.dateFormat = dateFormat
        format.locale = Locale(identifier: locale)
        return format.string(from: self)
    }
}


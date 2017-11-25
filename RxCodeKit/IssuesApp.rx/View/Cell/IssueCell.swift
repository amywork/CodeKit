//
//  IssueCell.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 23..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

final class IssueCell: UICollectionViewCell {
    @IBOutlet var stateButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var commentCountButton: UIButton!
}

extension IssueCell: CellProtocol {
    typealias Item = Model.Issue
    
    func update(data issue: Model.Issue) {
        titleLabel.text = issue.title
        contentLabel.text = issue.body
        let createdAt = issue.createdAt?.string(dateFormat: "dd MMM yyyy") ?? "-"
        contentLabel.text = "#\(issue.number) \(issue.state) on \(createdAt) by \(issue.user.login)"
        commentCountButton.setTitle("\(issue.comments)", for: .normal)
        stateButton.isSelected = issue.state == .closed
        let commentCountHidden: Bool = issue.comments == 0
        commentCountButton.isHidden = commentCountHidden
    }
}

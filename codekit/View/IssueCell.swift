//
//  IssueCell.swift
//  codekit
//
//  Created by 김기윤 on 04/11/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
class IssueCell: UICollectionViewCell {
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var commentCountButton: UIButton!
}

extension IssueCell {
    
    //cellFromNib을 호출할 때마다 NIB에서 하나씩 Cell을 가져온다.
    static var cellFromNib: IssueCell {
        guard let cell = Bundle.main.loadNibNamed("IssueCell", owner: nil, options: nil)?.first as? IssueCell else { return IssueCell() }
        return cell
    }
    
    func configureCell(data issue: Model.Issue) {
        titleLabel.text = issue.title
        //let createdAt: String = issue.createdAt?.string(dateFormat: "ddMMM") ?? "-"
        contentsLabel.text = "#\(issue.number) \(issue.state.rawValue) on createdAt by \(issue.user.login)"
        stateButton.isSelected = issue.state == .closed
        commentCountButton.setTitle("\(issue.comments)", for: .normal)
        let commentCountHidden = issue.comments == 0
        commentCountButton.isHidden = commentCountHidden
    }
}

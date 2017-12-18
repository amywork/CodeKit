//
//  IssueCommentCell.swift
//  CodeKitApp
//
//  Created by Kimkeeyun on 18/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
import AlamofireImage

final class IssueCommentCell: UICollectionViewCell {
    
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var commentContainerView: UIView!
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        commentContainerView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        commentContainerView.layer.borderWidth = 1
    }
    
}

extension IssueCommentCell: CellProtocol {
    typealias Item = Model.Comment
    
    static var cellFromNib: IssueCommentCell {
        guard let cell = Bundle.main.loadNibNamed("IssueCommentCell", owner: nil, options: nil)?.first as? IssueCommentCell else { return IssueCommentCell() }
        return cell
    }
    
    func configureCell(data comment: Model.Comment) {
        if let url = comment.user.avatarURL {
            profileImageView.af_setImage(withURL: url)
        }
        let createdAt = comment.createdAt?.string(dateFormat: "dd MM yyyy") ?? "-"
        titleLabel.text = "\(comment.user.login) commented on \(createdAt)"
        bodyLabel.text = comment.body
    }

}

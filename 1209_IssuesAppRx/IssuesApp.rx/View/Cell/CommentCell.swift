//
//  IssueCommentCell.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 10..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import AlamofireImage

final class CommentCell: UICollectionViewCell, CellProtocol {
    
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var commentContanerView: UIView!
    
    static var estimatedSizes: [IndexPath: CGSize] = [:]
    static let estimateCell: CommentCell = CommentCell.cellFromNib
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        commentContanerView.layer.borderWidth = 1
        commentContanerView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }
    
}

extension CommentCell {
    func update(data: Model.Comment) {
        update(data: data, withImage: true)
    }
    
    typealias Item = Model.Comment
    
    func update(data comment: Model.Comment, withImage: Bool = true) {
        if let url = comment.user.avatarURL {
            profileImageView.af_setImage(withURL: url)
        }
        
        let createdAt = comment.createdAt?.string(dateFormat: "dd MM yyyy") ?? "-"
        titleLabel.text = "\(comment.user.login) commented on \(createdAt)"
        bodyLabel.text = comment.body
    }

    
    static func cellSize(collectionView: UICollectionView, item: Model.Comment, indexPath: IndexPath) -> CGSize {
        var estimatedSize = estimatedSizes[indexPath] ?? CGSize.zero
        if estimatedSize != .zero {
            return estimatedSize
        }

        estimateCell.update(data: item)
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        estimatedSizes[indexPath] = estimatedSize
        return estimatedSize
    }
}

//
//  RecentChatsTableViewCell.swift
//  eChat
//
//  Created by Rose Maina on 29/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit

protocol RecentChatsTableViewCellDelegate {
    func didSelectAvatarImage(indexPath: IndexPath)
}

class RecentChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var messageCounterLabel: UILabel!
    @IBOutlet weak var messageCounterBackgroundView: UIView!
    
    var indexPath: IndexPath!
    var delegate: RecentChatsTableViewCellDelegate?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTapped))
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
        messageCounterBackgroundView.layer.cornerRadius = messageCounterBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc
    func avatarTapped() {
        delegate?.didSelectAvatarImage(indexPath: indexPath)
    }
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterBackgroundView.isHidden = false
            self.messageCounterLabel.isHidden = false
        } else {
            self.messageCounterBackgroundView.isHidden = true
            self.messageCounterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let createdDate = recentChat[kDATE] as? String {
            if (createdDate as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdDate)
            }
        } else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
    }
}

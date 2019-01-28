//
//  UserTableViewCell.swift
//  eChat
//
//  Created by Rose Maina on 25/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var indexPath: IndexPath!
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarIsTapped))
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension UserTableViewCell {
    @objc
    func avatarIsTapped() {
        print("Avatar is tapped at \(indexPath)")
    }
    
    func generateCellWith(fUser: FUser, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.fullNameLabel.text = fUser.fullname
        
        if fUser.avatar != "" {
            imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
}

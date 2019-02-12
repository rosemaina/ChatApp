//
//  ProfileViewViewModel.swift
//  eChat
//
//  Created by Rose Maina on 09/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation

class ProfileViewViewModel {
    
    var user: FUser?
    
    func blockUsers(viewController: ProfileViewTableViewController) {
        
        var currentBlockedIDs = FUser.currentUser()!.blockedUsers
        
        if currentBlockedIDs.contains(user!.objectId) {
            currentBlockedIDs.remove(at: currentBlockedIDs.index(of: user!.objectId)!)
        } else {
            currentBlockedIDs.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIDs]) { (error) in
            if error != nil {
                print("Error updating user \(String(describing: error?.localizedDescription))")
                return
            }
            self.updateBlockUserStatus(viewController: viewController)
        }
    }
    
    func setupUserInfo(viewController: ProfileViewTableViewController) {
        
        if user != nil {
            viewController.title = "Profile"
            viewController.fullNameLabel.text = user?.fullname
            viewController.phoneNumberLabel.text = user?.phoneNumber
            
            updateBlockUserStatus(viewController: viewController)
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    viewController.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    func updateBlockUserStatus(viewController: ProfileViewTableViewController) {

        if user!.objectId != FUser.currentId() {
            viewController.blockUserButton.isHidden = false
            viewController.callButton.isHidden = false
            viewController.messageButton.isHidden = false
        } else {
            viewController.blockUserButton.isHidden = true
            viewController.callButton.isHidden = true
            viewController.messageButton.isHidden = true
        }

        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            viewController.blockUserButton.setTitle("Unblock User", for: .normal)
        } else {
            viewController.blockUserButton.setTitle("Block User", for: .normal)
        }

    }
}

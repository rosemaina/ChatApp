//
//  ProfileViewTableViewController.swift
//  eChat
//
//  Created by Rose Maina on 28/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInfo()
    }
}

extension ProfileViewTableViewController {
    
    // MARK: - Table View DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20
    }
}

extension ProfileViewTableViewController {
    
    @IBAction func blockUserButtonTapped(_ sender: Any) {
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
            self.updateBlockUserStatus()
        }
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        print("Call user \(user!.fullname)")
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        print("Message user \(user!.fullname)")
    }
    
    func setupUserInfo() {
        if user != nil {
            self.title = "Profile"
            self.fullNameLabel.text = user?.fullname
            self.phoneNumberLabel.text = user?.phoneNumber
            
            updateBlockUserStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    func updateBlockUserStatus() {
        if user!.objectId != FUser.currentId() {
            self.blockUserButton.isHidden = false
            self.callButton.isHidden = false
            self.messageButton.isHidden = false
        } else {
            self.blockUserButton.isHidden = true
            self.callButton.isHidden = true
            self.messageButton.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockUserButton.setTitle("Unblock User", for: .normal)
        } else {
            blockUserButton.setTitle("Block User", for: .normal)
        }
    }
}

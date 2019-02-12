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
    
    var viewModel: ProfileViewViewModel = ProfileViewViewModel()
    
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
        viewModel.blockUsers(viewController: self)
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        print("Call user \(viewModel.user!.fullname)")
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        print("Message user \(viewModel.user!.fullname)")
    }
    
    func setupUserInfo() {
        viewModel.setupUserInfo(viewController: self)
    }
    
    func updateBlockUserStatus() {
        viewModel.updateBlockUserStatus(viewController: self)
    }
}

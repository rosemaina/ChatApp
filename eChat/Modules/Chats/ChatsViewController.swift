//
//  ChatsViewController.swift
//  eChat
//
//  Created by Rose Maina on 26/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func createNewChatButton(_ sender: Any) {
        
        let userVc = UsersTableViewController.instantiate(fromAppStoryboard: .Users)
        self.navigationController?.pushViewController(userVc, animated: true)
    }
}

//
//  SettingsTableViewController.swift
//  eChat
//
//  Created by Rose Maina on 25/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsTableViewController: UITableViewController {
    
    var viewModel: SettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SettingsViewModel()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension SettingsTableViewController {
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        viewModel.signOut(viewController: self)
    }
}

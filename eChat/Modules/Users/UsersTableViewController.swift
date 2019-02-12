//
//  UsersTableViewController.swift
//  eChat
//
//  Created by Rose Maina on 25/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Firebase
import ProgressHUD
import UIKit

class UsersTableViewController: UITableViewController {

    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)

    var viewModel: UsersViewModel = UsersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        viewModel.loadUsers(filter: kCITY, viewController: self)
    }
}

extension UsersTableViewController {
    
    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return viewModel.allUsersGrouped.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return viewModel.filteredUsers.count
        } else {
            
            // find section titles
            let sectionTitle = viewModel.sectionsTitleList[section]
            
            // users for a given section
            let users = viewModel.allUsersGrouped[sectionTitle]
            
            return users!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = viewModel.filteredUsers[indexPath.row]
        } else {
            let sectionTitle = viewModel.sectionsTitleList[indexPath.section]
            let users = viewModel.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    // MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return viewModel.sectionsTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        // return list of section titles to display in section index view (e.g. "ABCD...Z#")
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return viewModel.sectionsTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
       // tell table which section corresponds to section title/index (e.g. "B",1)
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = viewModel.filteredUsers[indexPath.row]
        } else {
            let sectionTitle = viewModel.sectionsTitleList[indexPath.section]
            let users = viewModel.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        
        // Cannot start private chat proparly for now //
        startPrivateChat(user1: FUser.currentUser()!, user2: user)
    }
}

extension UsersTableViewController: UserTableViewCellDelegate {
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.loadUsers(filter: kCITY, viewController: self)
        case 1:
            viewModel.loadUsers(filter: kCOUNTRY, viewController: self)
        case 2:
            viewModel.loadUsers(filter: "", viewController: self)
        default:
            return
        }
    }
    
    func didSelectAvatarImage(indexPath: IndexPath) {
        let profileViewVc = ProfileViewTableViewController.instantiate(fromAppStoryboard: .ProfileView)
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = viewModel.filteredUsers[indexPath.row]
        } else {
            let sectionTitle = viewModel.sectionsTitleList[indexPath.section]
            let users = viewModel.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        profileViewVc.viewModel.user = user
        self.navigationController?.pushViewController(profileViewVc, animated: true)
    }
}

extension UsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
       viewModel.filteredUsers = viewModel.allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

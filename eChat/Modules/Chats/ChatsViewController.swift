//
//  ChatsViewController.swift
//  eChat
//
//  Created by Rose Maina on 26/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ChatsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var viewModel: ChatsViewModel = ChatsViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.tableFooterView = UIView()
        viewModel.loadRecentChats(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       viewModel.recentListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setTableViewHeader()
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource mMthods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return viewModel.filteredChats.count
        } else {
            return viewModel.recentChats.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecentChatsTableViewCell
        cell.delegate = self
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
             recent = viewModel.filteredChats[indexPath.row]
        } else {
             recent = viewModel.recentChats[indexPath.row]
        }

        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempRecent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            tempRecent = viewModel.filteredChats[indexPath.row]
        } else {
            tempRecent = viewModel.recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.viewModel.recentChats.remove(at: indexPath.row)
            deleteRecentChat(recentChatDictionary: tempRecent)
            self.tableView.reloadData()
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            
            print("Mute \(indexPath)")
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        return [deleteAction, muteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = viewModel.filteredChats[indexPath.row]
        } else {
            recent = viewModel.recentChats[indexPath.row]
        }
        
        restartRecentChat(recent: recent)
        
        let chattingVc = ChattingViewController()
        chattingVc.hidesBottomBarWhenPushed = true
        chattingVc.viewModel.chatRoomId = recent[kCHATROOMID] as? String
        chattingVc.viewModel.memberIds = recent[kMEMBERS] as? [String]
        chattingVc.viewModel.membersToPush = recent[kMEMBERSTOPUSH] as? [String]
        chattingVc.viewModel.titleName = recent[kWITHUSERFULLNAME] as? String
        chattingVc.viewModel.isGroup = (recent[kTYPE] as! String) == kGROUP

        navigationController?.pushViewController(chattingVc, animated: true)
    }
}

extension ChatsViewController: RecentChatsTableViewCellDelegate {
    @IBAction func createNewChatButton(_ sender: Any) {
        
        let userVc = UsersTableViewController.instantiate(fromAppStoryboard: .Users)
        self.navigationController?.pushViewController(userVc, animated: true)
    }
    
    @objc
    func groupButtonTapped() {
        
    }
    
    func setTableViewHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonTapped), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
    }
    
    func didSelectAvatarImage(indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
           viewModel.recentChat = viewModel.filteredChats[indexPath.row]
        } else {
            viewModel.recentChat = viewModel.recentChats[indexPath.row]
        }
        
        viewModel.selectAvatar(viewController: self)
    }
}

extension ChatsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        viewModel.filteredChats = viewModel.recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}

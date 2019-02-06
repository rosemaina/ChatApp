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
    
    var filteredChats: [NSDictionary] = []
    var recentChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.tableFooterView = UIView()
        loadRecentChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
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
            return filteredChats.count
        } else {
            return recentChats.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecentChatsTableViewCell
        cell.delegate = self
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
             recent = filteredChats[indexPath.row]
        } else {
             recent = recentChats[indexPath.row]
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
            tempRecent = filteredChats[indexPath.row]
        } else {
            tempRecent = recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
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
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        
        restartRecentChat(recent: recent)
        
        let chattingVc = ChattingViewController()
        chattingVc.hidesBottomBarWhenPushed = true
        chattingVc.chatRoomId = recent[kCHATROOMID] as? String
        chattingVc.memberIds = recent[kMEMBERS] as? [String]
        chattingVc.membersToPush = recent[kMEMBERSTOPUSH] as? [String]
        chattingVc.titleName = recent[kWITHUSERFULLNAME] as? String

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
    
    func loadRecentChats() {
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                self.tableView.reloadData()
            }
        })
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
        
        var recentChat: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recentChat = filteredChats[indexPath.row]
        } else {
            recentChat = recentChats[indexPath.row]
        }
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    
                    self.showUserProfile(user: tempUser)
                }
            }
        }
    }
    
    func showUserProfile(user: FUser) {
        let profileViewVc = ProfileViewTableViewController.instantiate(fromAppStoryboard: .ProfileView)
        profileViewVc.user = user
        self.navigationController?.pushViewController(profileViewVc, animated: true)
    }
}

extension ChatsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}

//
//  ChatsViewModel.swift
//  eChat
//
//  Created by Rose Maina on 10/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import FirebaseFirestore
import Foundation

class ChatsViewModel {
    
    var filteredChats: [NSDictionary] = []
    var recentChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
     var recentChat: NSDictionary!
    
    func selectAvatar(viewController: ChatsViewController) {
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    
                    self.showUserProfile(user: tempUser, viewController: viewController)
                }
            }
        }
    }
    
    func showUserProfile(user: FUser, viewController: ChatsViewController) {
        let profileViewVc = ProfileViewTableViewController.instantiate(fromAppStoryboard: .ProfileView)
        profileViewVc.viewModel.user = user
        viewController.navigationController?.pushViewController(profileViewVc, animated: true)
    }
    
    func loadRecentChats(viewController: ChatsViewController) {
        
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
                viewController.tableView.reloadData()
            }
        })
    }
}

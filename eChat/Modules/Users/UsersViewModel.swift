//
//  UsersViewModel.swift
//  eChat
//
//  Created by Rose Maina on 10/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Firebase
import Foundation
import ProgressHUD

class UsersViewModel {
    
    var allUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String: [FUser]]
    var filteredUsers: [FUser] = []
    var sectionsTitleList: [String] = []
    
    func loadUsers(filter: String, viewController: UsersTableViewController) {
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapShot, error) in
            
            self.allUsers = []
            self.sectionsTitleList = []
            self.allUsersGrouped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                viewController.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapShot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser.init(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                
                self.splitDataIntoSections()
                viewController.tableView.reloadData()
            }
            viewController.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    func splitDataIntoSections() {
        
        var sectionTitle: String = ""
        
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            let firstCharacter = currentUser.firstname.first
            let firstCharacterString = String(firstCharacter!)
            
            if firstCharacterString != sectionTitle {
                sectionTitle = firstCharacterString
                
                self.allUsersGrouped[sectionTitle] = []
                self.sectionsTitleList.append(sectionTitle)
            }
            self.allUsersGrouped[firstCharacterString]?.append(currentUser)
        }
    }
}

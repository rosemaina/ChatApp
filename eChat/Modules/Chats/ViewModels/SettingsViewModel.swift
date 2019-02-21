//
//  SettingsViewModel.swift
//  eChat
//
//  Created by Rose Maina on 13/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation


class SettingsViewModel {
    
    private let auth: AuthManagerProtocol
    
    init(auth: AuthManagerProtocol = Auth.auth()) {
        self.auth = auth
    }
    
    func signOut(viewController: SettingsTableViewController) {
        userDefaults.removeObject(forKey: kPUSHID )
        removeOneSignalId()
        
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        do {
            try auth.signOut()
            let signInVc = SignInViewController.instantiate(fromAppStoryboard: .SignIn)
            viewController.present(signInVc, animated: true, completion: nil)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

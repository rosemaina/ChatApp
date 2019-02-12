//
//  SignInViewModel.swift
//  eChat
//
//  Created by Rose Maina on 08/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import ProgressHUD
import FirebaseAuth
import FirebaseFirestore

class SignInViewModel {
    
    private let auth: AuthManagerProtocol
    
    init(auth: AuthManagerProtocol = Auth.auth()) {
        self.auth = auth
    }
    
    func loginUser(email: String, password: String, viewController: SignInViewController) {
        ProgressHUD.show("Login...")

        auth.signIn(withEmail: email, password: password) { (firebaseUser, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            // get user from firebase and save locally
            fetchCurrentUserFromFirestore(userId: firebaseUser!.user.uid)
            self.goToApp(viewController: viewController)
        }
    }
        
//        Auth.auth().signIn(withEmail: email, password: password, completion: { (firebaseUser, error) in
//            if error != nil {
//                ProgressHUD.showError(error!.localizedDescription)
//                return
//            }
//
//            // get user from firebase and save locally
//            fetchCurrentUserFromFirestore(userId: firebaseUser!.user.uid)
//            self.goToApp(viewController: viewController)
//        })
//    }
    
    func goToApp(viewController: SignInViewController) {
        ProgressHUD.dismiss()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Chats", bundle: nil).instantiateViewController(withIdentifier: "mainApp") as! UITabBarController
        viewController.present(mainView, animated: true, completion: nil)
    }
}

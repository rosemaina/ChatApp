//
//  SignInViewModel.swift
//  eChat
//
//  Created by Rose Maina on 08/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import ProgressHUD

class SignInViewModel {
    
    // MARK: - Private Methods
    
    func loginUser(email: String, password: String, viewController: SignInViewController) {
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: email, password: password) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            self.goToApp(viewController: viewController)
        }
    }
    
    func goToApp(viewController: SignInViewController) {
        ProgressHUD.dismiss()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Chats", bundle: nil).instantiateViewController(withIdentifier: "mainApp") as! UITabBarController
        viewController.present(mainView, animated: true, completion: nil)
    }
}

//
//  SignUpViewModel.swift
//  eChat
//
//  Created by Rose Maina on 08/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import ProgressHUD

class SignUpViewModel {
    
    func signUp(email: String?, password: String?, confirmPassword: String?, viewController: SignUpViewController) {
        
        guard let email = email, let password = password, let confirm = confirmPassword else {
            ProgressHUD.showError("All fields are required!")
            return
        }
        
        guard password == confirm else {
            ProgressHUD.showError("Passwords dont match!")
            return
        }
        
        let profileVc = ProfileViewController.instantiate(fromAppStoryboard: .Profile)
        profileVc.viewModel.email = email
        profileVc.viewModel.password = password
        
        viewController.present(profileVc, animated: true, completion: nil)
    }
}

//
//  ProfileViewModel.swift
//  eChat
//
//  Created by Rose Maina on 08/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import ProgressHUD

class ProfileViewModel {
    
    var avatarImage: UIImage!
    var email: String!
    var password: String!
    
    func clickdoneButton(firstName: String?, surname: String?, country: String?, city: String?, phoneNumber: String?, viewController: ProfileViewController) {
        
        guard let firstName = firstName, let surname = surname, let country = country, let city = city, let phoneNumber = phoneNumber
            else {
                ProgressHUD.showError("All fields are required!")
                return }
        
        FUser.registerUserWith(email: email!, password: password!, firstName: firstName, lastName: surname) { (error) in
            if error != nil {
                ProgressHUD.dismiss()
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            self.registerUser(firstName: firstName, surname: surname, country: country, city: city, phoneNumber: phoneNumber, viewController: viewController)
        }
    }
    
    func registerUser(firstName: String, surname: String, country: String, city: String, phoneNumber: String, viewController: ProfileViewController) {
        
        let fullName = firstName + " " + surname
        
        var tempDictionary : Dictionary = [kFIRSTNAME : firstName,
                                           kLASTNAME : surname,
                                           kFULLNAME : fullName,
                                           kCOUNTRY : country,
                                           kCITY : city,
                                           kPHONE : phoneNumber] as [String : Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: firstName, lastName: surname) { (avatarInitials) in
                
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary, viewController: viewController)
            }
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.5)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDictionary[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDictionary, viewController: viewController)
        }
    }
    
    func finishRegistration(withValues: [String : Any], viewController: ProfileViewController) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            self.goToApp(viewController: viewController)
        }
    }
    
    func goToApp(viewController: ProfileViewController) {
        ProgressHUD.dismiss()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Chats", bundle: nil).instantiateViewController(withIdentifier: "mainApp") as! UITabBarController
        viewController.present(mainView, animated: true, completion: nil)
    }
}

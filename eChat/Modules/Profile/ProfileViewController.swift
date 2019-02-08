//
//  ProfileViewController.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import ProgressHUD
import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    var avatarImage: UIImage!
    var email: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
        let textFields = [self.cityTextField, self.countryTextField, self.nameTextField, self.phoneTextField, self.surnameTextField]
        
        for textField in textFields {
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
}

extension ProfileViewController {
    
    @IBAction func cancellButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        ProgressHUD.show("Registering...")
        
        if nameTextField.text != "" && surnameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
            
            FUser.registerUserWith(email: email!, password: password!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                self.registerUser()
            }
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    func registerUser() {
        
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDictionary : Dictionary = [kFIRSTNAME : nameTextField.text!,
                                           kLASTNAME : surnameTextField.text!,
                                           kFULLNAME : fullName,
                                           kCOUNTRY : countryTextField.text!,
                                           kCITY : cityTextField.text!,
                                           kPHONE : phoneTextField.text!] as [String : Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

                tempDictionary[kAVATAR] = avatar

                self.finishRegistration(withValues: tempDictionary)
            }
        } else {

            let avatarData = avatarImage?.jpegData(compressionQuality: 0.5)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

            tempDictionary[kAVATAR] = avatar

            self.finishRegistration(withValues: tempDictionary)
        }
    }

    func finishRegistration(withValues: [String : Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in

            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func goToApp() {
        ProgressHUD.dismiss()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Chats", bundle: nil).instantiateViewController(withIdentifier: "mainApp") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
}


extension ProfileViewController {
    
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc
    func textFieldDidChange(_ textfield: UITextField) {
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero).height
        let animationDuration: Double = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let animationCurve: UInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: options,
                       animations: {
                        self.bottomScrollViewConstraint.constant = 10 + keyboardHeight
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let animationDuration: Double = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let animationCurve: UInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: options,
                       animations: {
                        self.bottomScrollViewConstraint.constant = 112
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
}

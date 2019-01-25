//
//  SignUpViewController.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import ProgressHUD
import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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

extension SignUpViewController {
  
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickToSignUp(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            if passwordTextField.text == confirmPasswordTextField.text {
                let profileVc = ProfileViewController.instantiate(fromAppStoryboard: .Profile)
                profileVc.email = emailTextField.text!
                profileVc.password = passwordTextField.text!
                
                self.present(profileVc, animated: true, completion: nil)
            } else {
                ProgressHUD.showError("Passwords dont match!")
            }            
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    func goToApp() {
        ProgressHUD.dismiss()
        
        let mainView = UIStoryboard.init(name: "Chats", bundle: nil).instantiateViewController(withIdentifier: "mainApp") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
}

// MARK:- KeyBoard Methods
extension SignUpViewController {
    
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
                        // Do animations for IBOutlets here
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
                        // Do animations for IBOutlets here
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
}

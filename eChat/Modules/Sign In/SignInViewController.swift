//
//  SignInViewController.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import ProgressHUD
import UIKit

class SignInViewController: UIViewController {

    //MARK:- Private Instance Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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

// MARK:- Instance Methods
extension SignInViewController {
    
    @IBAction func clickToSignUp(_ sender: UIButton) {
      let signUpVc = SignUpViewController.instantiate(fromAppStoryboard: .SignUp)
        self.present(signUpVc, animated: true, completion: nil)
    }
    
    @IBAction func clickToSignIn(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            loginUser()
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    func loginUser() {
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
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

// MARK:- KeyBoard Methods
extension SignInViewController {
    
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

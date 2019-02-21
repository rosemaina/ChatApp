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
    
    var viewModel: SignInViewModel!
    
    @IBOutlet weak var bottomSignInConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SignInViewModel()
    
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        signInButton.layer.cornerRadius = 6
        
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

extension SignInViewController {

    @IBAction func clickToSignUp(_ sender: UIButton) {
      let signUpVc = SignUpViewController.instantiate(fromAppStoryboard: .SignUp)
        self.present(signUpVc, animated: true, completion: nil)
    }

    @IBAction func clickToSignIn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            viewModel.loginUser(email: emailTextField.text!,
                                password: passwordTextField.text!,
                                viewController: self)
        } else {
            ProgressHUD.showError("All fields are required!")
        }
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
                        self.bottomSignInConstraint.constant = 10 + keyboardHeight
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
                        self.bottomSignInConstraint.constant = 36
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
}

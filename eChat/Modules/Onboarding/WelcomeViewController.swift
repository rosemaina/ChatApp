//
//  WelcomeViewController.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        let signInVc = SignInViewController.instantiate(fromAppStoryboard: .SignIn)
        self.present(signInVc, animated: true, completion: nil)
    }
}

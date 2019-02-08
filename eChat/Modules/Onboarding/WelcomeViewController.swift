//
//  WelcomeViewController.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton.layer.cornerRadius = 6
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        let signInVc = SignInViewController.instantiate(fromAppStoryboard: .SignIn)
        self.present(signInVc, animated: true, completion: nil)
    }
}

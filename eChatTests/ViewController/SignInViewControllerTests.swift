//
//  SignInViewControllerTests.swift
//  eChatTests
//
//  Created by Rose Maina on 13/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import Quick
import Nimble
import FirebaseAuth
import FirebaseFirestore

@testable import eChat

class SignInViewControllerTests: QuickSpec {
    override func spec() {
        
        var sut: SignInViewController!
        var viewModel: SignInViewModel!
        
        describe("The Sign In View Controller") {
            afterEach {
                sut = nil
            }
            
            beforeEach {
                
                sut = SignInViewController.instantiate(fromAppStoryboard: .SignIn)
                viewModel = SignInViewModel()
                
                sut.viewModel = viewModel
            }
            
            it("view is present") {
                expect(sut.view).toNot(beNil())
            }
            
            it("login func is called") {
//                expect(sut.clickToSignIn(sut.signInButton)).toEventually(be(sut.emailTextField.text))
//                expect(sut.clickToSignIn(sut.signInButton)).toEventually(be(sut.passwordTextField.text))
            }
            
            it("button sign up clicked") {
//                let signUpVc = SignUpViewController.instantiate(fromAppStoryboard: .SignUp)
//                expect(sut.clickToSignUp(sut.signUpButton)).to(be(signUpVc))
            }
            
            
            
        }     
    }
}

//
//  SignInViewModelTests.swift
//  eChatTests
//
//  Created by Rose Maina on 11/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import Quick
import Nimble
import FirebaseAuth
import FirebaseFirestore

@testable import eChat

class SignInViewModelTests: QuickSpec {
    override func spec() {
        
        var sut: SignInViewModel!
        let authManager = MockAuthManager()

        describe("The SignIn View Model") {
            let signInVc = SignInViewController()

            context("is validated with the correct parameters") {
                afterEach {
                    sut = nil
                }

                beforeEach {
                    sut = SignInViewModel()
                }

                it("user signs in with correct params") {
                    sut.loginUser(email: MockFUser.email, password: MockFUser.password, viewController: signInVc)
                    
                    guard
                        let (email, password) = authManager.signIn_called_withArgs
                        else { return }
                    
                    expect(email).to(equal(MockFUser.email))
                    expect(password).to(equal(MockFUser.password))
                }
            }
        }
    }
}

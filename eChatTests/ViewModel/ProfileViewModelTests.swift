//
//  ProfileViewModelTests.swift
//  eChatTests
//
//  Created by Rose Maina on 12/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import Quick
import Nimble
import FirebaseAuth
import FirebaseFirestore

@testable import eChat

class ProfileViewModelTests: QuickSpec {
    override func spec() {
        
        var sut: ProfileViewModel!
        let authManager = MockAuthManager()
        let profileVc = ProfileViewController()
        
        describe("The SignIn View Model") {
            
            context("is validated with the correct parameters") {
                afterEach {
                    sut = nil
                }
                
                beforeEach {
                    sut = ProfileViewModel()
                }
                
                it("user registers with correct params") {
                    sut.registerUser(firstName: MockFUser.firstname,
                                     surname: MockFUser.lastname,
                                     country: MockFUser.country,
                                     city: MockFUser.city,
                                     phoneNumber: MockFUser.phoneNumber,
                                     viewController: profileVc)
                    
                    guard
                        let (email, password) = authManager.createUser_called_withArgs
                        else { return }
                    
                    expect(email).to(equal(MockFUser.email))
                    expect(password).to(equal(MockFUser.password))
                }
            }
        }
    }
}

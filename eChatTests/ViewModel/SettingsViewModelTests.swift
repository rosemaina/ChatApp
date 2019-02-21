//
//  SettingsViewModelTests.swift
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

class SettingsViewModelTests: QuickSpec {
    override func spec() {
        
        var sut: SettingsViewModel!
        let authManager = MockAuthManager()
        let settingsTableVc = SettingsTableViewController()
        
        describe("The Settings View Model") {
            
            context("user is logged out") {
                afterEach {
                    sut = nil
                }
                
                beforeEach {
                    sut = SettingsViewModel(auth: authManager)
                }
                
                it("logs out user") {
                    sut.signOut(viewController: settingsTableVc)
                    
                    expect(authManager.signOut_called).to(beTrue())
                }
            }
        }
    }
}

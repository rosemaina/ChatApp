//
//  MockFUser.swift
//  eChat
//
//  Created by Rose Maina on 12/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

class MockFUser{
    
    static let objectId = "mBcjPPVKaUfxuNbdt7zvwLk95qU2"
    static let pushId = ""
    
    static let createdAt = "20190128184451"
    static let updatedAt = ""
    
    static let email = "rose.maina@mail.com"
    static let password = "12345678"
    
    static let firstname = "Rose"
    static let lastname = "Maina"
    static let fullname = "Rose" + " " + "Maina"
    
    static let isOnline = true
    
    static let city = "Nairobi"
    static let country = "USA"
    
    static let loginMethod = "email"
    static let phoneNumber = "4455667788"
    static let countryCode = ""
    static let blockedUsers = [String]()
    static let contacts = [String]()
    
    static let avatar = "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"
}

//
//  MockAuthManager.swift
//  eChat
//
//  Created by Rose Maina on 12/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class MockAuthManager: AuthManagerProtocol {

    var signIn_called_withArgs: (String, String)?
    var createUser_called_withArgs: (String, String)?
    
    func signIn(withEmail: String, password: String, completion: AuthDataResultCallback?) {
        signIn_called_withArgs = (withEmail, password)
    }
    
    func createUser(withEmail: String, password: String, completion: AuthDataResultCallback?) {
        createUser_called_withArgs = (withEmail, password)
    }
}

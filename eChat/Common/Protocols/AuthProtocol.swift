//
//  AuthProtocol.swift
//  eChat
//
//  Created by Rose Maina on 12/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol AuthManagerProtocol {
    func signIn(withEmail: String, password: String, completion: AuthDataResultCallback?)
    func createUser(withEmail: String, password: String, completion: AuthDataResultCallback?)
}

extension Auth: AuthManagerProtocol { }


//
//  FCollectionReference.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}

func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}

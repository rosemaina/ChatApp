//
//  IncomingMessages.swift
//  eChat
//
//  Created by Rose Maina on 04/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessages {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String)-> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            print("picture")
        case kVIDEO:
            print("video")
        case kAUDIO:
            print("audio")
        case kLOCATION:
            print("location")
        default:
            print("Unknown message type")
        }
        
        if message != nil {
            return message
        }
        return nil
    }
    
    func createTextMessage(messageDictionay: NSDictionary, chatRoomId: String) -> JSQMessage {
        let name = messageDictionay[kSENDERNAME] as! String
        let userId = messageDictionay[kSENDERID] as! String
        
        var date: Date!
        
        if let created = messageDictionay[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
             date = Date()
        }
        let message = messageDictionay[kMESSAGE] as! String
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: message)
    }
}

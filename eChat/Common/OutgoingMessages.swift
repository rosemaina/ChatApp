//
//  OutgoingMessages.swift
//  eChat
//
//  Created by Rose Maina on 04/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation

class OutgoingMessages {
    
    let messageDictionary: NSMutableDictionary
    
    // MARK: - Initializers
    
    // TEXT
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message,
                                                          senderId,
                                                          senderName,
                                                          dateFormatter().string(from: date),
                                                          status,
                                                          type],
                                                forKeys: [kMESSAGE as NSCopying,
                                                          kSENDERID as NSCopying,
                                                          kSENDERNAME as NSCopying,
                                                          kDATE as NSCopying,
                                                          kSTATUS as NSCopying,
                                                          kTYPE as NSCopying])
    }
    
    // PICTURE
    init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = NSMutableDictionary(objects: [message,
                                                          pictureLink,
                                                          senderId,
                                                          senderName,
                                                          dateFormatter().string(from: date),
                                                          status,
                                                          type],
                                                forKeys: [kMESSAGE as NSCopying,
                                                          kPICTURE as NSCopying,
                                                          kSENDERID as NSCopying,
                                                          kSENDERNAME as NSCopying,
                                                          kDATE as NSCopying,
                                                          kSTATUS as NSCopying,
                                                          kTYPE as NSCopying])
    }
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
        }
        
        // Update recent to include date and time
        // send push notifications
        
    }
}

//
//  ChattingViewModel.swift
//  eChat
//
//  Created by Rose Maina on 10/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import AVFoundation
import AVKit
import FirebaseFirestore
import Foundation
import IDMPhotoBrowser
import IQAudioRecorderController
import JSQMessagesViewController
import ProgressHUD

class ChattingViewModel {
    
    var chatRoomId: String!
    var group: NSDictionary?
    var isGroup: Bool?
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var withUsers: [FUser] = []
    
    var loadOldChats = false
    var loadedMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    
    var allPictureMessages: [String] = []
    var loadedMessages: [NSDictionary] = []
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    
    var initialLoadComplete = false
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    let correctTypes = [kTEXT, kPICTURE, kVIDEO, kLOCATION, kAUDIO]
    
    //MARK: - Load Messages
    
    func loadMessages(viewController: ChattingViewController) {
        // get last 11 messages
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                // listen for new chats
                
                return
            }
            
            // sort using date
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            // remove bad messages
            self.loadedMessages = self.removeAllBadMessages(allMessages: sorted)
            
            self.insertMessage(viewController: viewController)
            viewController.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            
            print("We have \(self.messages.count) messages!!!!!")
            
            // get picture messges
            self.getOldMessagesInBackGround()
            self.listenForNewChats(viewController: viewController)
        }
    }
    
    func listenForNewChats(viewController: ChattingViewController) {
        var lastMessageDate = "0"
        
        if loadedMessages.count > 0 {
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                // called every time we add, delete, update objects
                
                for diff in snapshot.documentChanges {
                    if (diff.type == .added) {
                        let itemAdded = diff.document.data() as NSDictionary
                        
                        if let type = itemAdded[kTYPE] {
                            if self.correctTypes.contains(type as! String) {
                                
                                // for picture messages
                                if type as! String == kPICTURE {
                                    // add pictures
                                }
                                // just sendfing the message
                                if self.insertInitialLoadMessage(messageDictionary: itemAdded, viewController: viewController) {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                viewController.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func getOldMessagesInBackGround() {
        if loadedMessages.count > 10 {
            
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                self.loadedMessages = self.removeAllBadMessages(allMessages: sorted) + self.loadedMessages
                
                //                self.getPictureMessages()
                
                self.maxMessageNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
            }
        }
    }
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int, viewController: ChattingViewController) {
        
        if loadOldChats {
            maxMessageNumber = minMessageNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            let messageDictionary = loadedMessages[i]
            
            insertNewMessage(messageDictionary: messageDictionary, viewController: viewController)
            loadedMessagesCount += 1
        }
        
        loadOldChats = true
        viewController.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary, viewController: ChattingViewController) {
        let incomingMessage = IncomingMessage(collectionView_: viewController.collectionView!)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        // insert into object messages and JSQmessages
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    // MARK: - Insert Messages
    
    func insertMessage(viewController: ChattingViewController) {
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessages[i]
            
            self.insertInitialLoadMessage(messageDictionary: messageDictionary, viewController: viewController)
            
            loadedMessagesCount += 1
        }
        viewController.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertInitialLoadMessage(messageDictionary: NSDictionary, viewController: ChattingViewController) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: viewController.collectionView!)
        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            // update message status
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    // MARK: - Send Messages
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?, viewController: ChattingViewController) {
        var outgoingMessage: OutgoingMessages?
        let currentUser = FUser.currentUser()!
        
        //text message
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text,
                                               senderId: currentUser.objectId,
                                               senderName: currentUser.firstname,
                                               date: date,
                                               status: kDELIVERED,
                                               type: kTEXT)
        }
        
        // picture message
        if let pic = picture {
            uploadImage(image: pic, chatRoomId: chatRoomId, view: viewController.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    let text = kPICTURE
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    viewController.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            }
            
            return
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        viewController.finishSendingMessage()
        
        outgoingMessage?.sendMessage(chatRoomId: chatRoomId,
                                     messageDictionary: outgoingMessage!.messageDictionary,
                                     memberIds: memberIds,
                                     membersToPush: membersToPush)
    }
    
    // MARK: - Helper Functions
    
    func removeAllBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        var tempMessages = allMessages
        
        for message in tempMessages {
            if message[kTYPE] != nil {
                if !self.correctTypes.contains(message[kTYPE] as! String) {
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
        }
        return tempMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    func readTimeFrom(dateString: String) -> String {
        let date = dateFormatter().date(from: dateString)
        
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        
        return currentDateFormat.string(from: date!)
    }
}

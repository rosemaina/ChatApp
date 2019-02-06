//
//  ChattingViewController.swift
//  eChat
//
//  Created by Rose Maina on 31/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import AVFoundation
import AVKit
import FirebaseFirestore
import IDMPhotoBrowser
import IQAudioRecorderController
import JSQMessagesViewController
import ProgressHUD
import UIKit

class ChattingViewController: JSQMessagesViewController {
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    // Fix for iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.clickBackButton))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
//        fix for Iphone x
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        end of iphone x fix
        
//        custom send button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
    }
}

extension ChattingViewController {
    
    @objc
    func clickBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - JSQMessages Delegate Methods
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideoAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        let sharePhotoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("Photo library")
        }
        let shareVideoAction = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("Video library")
        }
        let shareLocationAction = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("Share Location")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        takePhotoOrVideoAction.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhotoAction.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideoAction.setValue(UIImage(named: "video"), forKey: "image")
        shareLocationAction.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideoAction)
        optionMenu.addAction(sharePhotoAction)
        optionMenu.addAction(shareVideoAction)
        optionMenu.addAction(shareLocationAction)
        optionMenu.addAction(cancelAction)
        
        // To avoid a crash on an iPad
        if ( UI_USER_INTERFACE_IDIOM() == .pad ) {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController {
                
                currentPopoverpresentioncontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentioncontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessages(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        } else {
            print("audio message")
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
    }
    
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    func sendMessages(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
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
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        outgoingMessage?.sendMessage(chatRoomId: chatRoomId,
                                     messageDictionary: outgoingMessage!.messageDictionary,
                                     memberIds: memberIds,
                                     membersToPush: membersToPush)
    }
}

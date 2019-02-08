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
    
    // Custom Headers
    let avatarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    
    let leftBarButtonView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
   
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        
        return subTitle
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        
        return title
    }()
        
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
        
        setCustomTitle()
        loadMessages()
        
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
    // MARK: - Instance Methods
    @objc
    func clickBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func clickInfoButton() {
        print("show image messages")
    }
    
    @objc
    func showGroup() {
       print("show image messages")
    }
    
    @objc
    func showUserProfile() {
        let profileViewVc = ProfileViewTableViewController.instantiate(fromAppStoryboard: .ProfileView)
        profileViewVc.user = withUsers.first
        self.navigationController?.pushViewController(profileViewVc, animated: true)
    }
    
    // MARK: - Setup UI Methods
    
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    func setCustomTitle() {
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.clickInfoButton))
        self.navigationItem.rightBarButtonItem = infoButton
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        } else {
            avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            self.withUsers = withUsers
            //get avatars
            
            if !self.isGroup! {
                self.setSingleChatUI()
            }
        }
    }
    
    func setSingleChatUI() {
        let withUser = withUsers.first!
        
        imageFromData(pictureData: withUser.avatar) { (avatar) in
            if avatar != nil {
                avatarButton.setImage(avatar?.circleMasked, for: .normal)
            }
        }
        
        titleLabel.text = withUser.fullname
        
        if withUser.isOnline {
            subTitleLabel.text = "Online"
        } else {
            subTitleLabel.text = "Offline"
        }
        
        avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
    }
    
    //MARK: - Load Messages
    
    func loadMessages() {
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
            
            self.insertMessage()
            self.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            
            print("we hace messages \(self.messages.count)")
            
            // get picture messges
            self.getOldMessagesInBackGround()
            self.listenForNewChats()
        }
    }
    
    func listenForNewChats() {
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
                                if self.insertInitialLoadMessage(messageDictionary: itemAdded) {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                self.finishReceivingMessage()
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
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        if loadOldChats {
            maxMessageNumber = minMessageNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            let messageDictionary = loadedMessages[i]
            
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        loadOldChats = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary) {
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        // insert into object messages and JSQmessages
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    // MARK: - Insert Messages
    
    func insertMessage() {
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessages[i]
            
            self.insertInitialLoadMessage(messageDictionary: messageDictionary)
            
            loadedMessagesCount += 1
        }
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertInitialLoadMessage(messageDictionary: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
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
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
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
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    let text = kPICTURE
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            }
            
            return
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage?.sendMessage(chatRoomId: chatRoomId,
                                     messageDictionary: outgoingMessage!.messageDictionary,
                                     memberIds: memberIds,
                                     membersToPush: membersToPush)
    }
    
    // end
}

extension ChattingViewController {

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

extension ChattingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - JSQMessages DataSource Methods
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        // Displays our messages
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objectMessages[indexPath.row]
        
        let status: NSAttributedString!
        
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        
        switch message[kSTATUS] as! String {
            
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
            
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
            
        default:
            status = NSAttributedString(string: "✔︎")
        }
        
        if indexPath.row == (messages.count - 1) {
            return status
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    // MARK: - JSQMessages Delegate Methods
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideoAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        
        let sharePhotoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
        self.collectionView.reloadData()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
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
    
    
    
    
    
    
    
    //MARK: - UIImagePickerController Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

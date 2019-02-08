//
//  PhotoMediaItem.swift
//  eChat
//
//  Created by Rose Maina on 07/02/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import JSQMessagesViewController
import Foundation

class PhotoMediaItem: JSQPhotoMediaItem {
    
    override func mediaViewDisplaySize() -> CGSize {
        
        let defaultSize : CGFloat = 256
        
        var thumbSize : CGSize = CGSize(width: defaultSize, height: defaultSize)
        
        if (self.image != nil && self.image.size.height > 0 && self.image.size.width > 0) {
            let aspectRatio: CGFloat = self.image.size.width / self.image.size.height
            
            // check if image is landscape/potrait
            if (self.image.size.width > self.image.size.height) {
                thumbSize = CGSize(width: defaultSize, height: defaultSize / aspectRatio)
            } else {
                thumbSize = CGSize(width: defaultSize * aspectRatio, height: defaultSize)
            }
        }
        return thumbSize
    }
}

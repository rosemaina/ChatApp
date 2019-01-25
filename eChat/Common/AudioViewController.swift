//
//  AudioViewController.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioViewController {

    var delegate: IQAudioRecorderViewControllerDelegate

    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target: UIViewController) {

        let controller = IQAudioRecorderViewController()

        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true

        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}

//
//  UIViewController+Extension.swift
//  eChat
//
//  Created by Rose Maina on 24/01/2019.
//  Copyright © 2019 Rose Maina. All rights reserved.
//

import UIKit
import Foundation

public enum AppStoryboard: String {
    case Main
    case Chats
    case Profile
    case ProfileView
    case SignIn
    case SignUp
    case Users

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T: UIViewController>(viewControllerClass: T.Type, identifier: String? = nil) -> T {
        let storyboardId = identifier ?? (viewControllerClass as UIViewController.Type).storyboardID

        guard let scene = instance.instantiateViewController(withIdentifier: storyboardId) as? T else {
            fatalError("Viewcontroller with ID \(storyboardId), not found in \(self.rawValue) Storyboard")
        }
        return scene
    }
}

extension UIViewController {
    
    class var storyboardID: String {
        return "\(self)"
    }

    public static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard, withIdentifier identifier: String? = nil) -> Self {
        return appStoryboard.viewController(viewControllerClass: self, identifier: identifier)
    }

    func animate(constraint: NSLayoutConstraint, toConstant constant: CGFloat, withDuration duration: TimeInterval) {
        constraint.constant = constant
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    var appDelegate: AppDelegate {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate
        } else {
            fatalError("UIApplication Delegate isn't an instance of AppDelegate")
        }
    }
}

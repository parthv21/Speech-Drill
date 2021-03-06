//
//  SideNavigationVCActions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import UIKit

extension SideNavigationController {
    
    @objc func closeViewWithEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        logger.event("Closing side nav with edge swipe")
        
        guard let calledFromVCIndex = calledFromVCIndex else { return }
        
        let presentedVC = getSideNavMenuItem(at: calledFromVCIndex).presentedVC
        
        if !(navigationController?.topViewController?.isKind(of: type(of: presentedVC)) ?? true) {
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: presentedVC))".lowercased()])
        
    }
    
    @objc func viewDiscussions(with userInfo: [AnyHashable : Any], viewAnimated: Bool = true ) {
        logger.event("Viewing discussion for notification with user info \(userInfo)")
        
        var messageID: String? = nil
        var messageTimestamp: Double = 0
        
        if let dict = userInfo as? [String: Any] {
            if let userInfoMessageID = dict["messageID"] as? String { messageID = userInfoMessageID }
            if let userInfoMessageTimestamp = dict["messageTimestamp"] as? String {
                messageTimestamp =  Double(userInfoMessageTimestamp) ?? 0
            }
        }
        
//        guard let presentedVC = menuItems[1].presentedVC as? DiscussionsViewController else { return }

        guard let presentedVC = menuItems[.DISCUSSIONS]?.presentedVC as? DiscussionsViewController else { return }

        guard let alreadyPresentedDiscussions = navigationController?.topViewController?.isKind(of: type(of: presentedVC)) else { return }
        
        guard let alreadyPresentingSideNavigationController = navigationController?.topViewController?.isKind(of: type(of: self)) else { return }
        
        if  !alreadyPresentedDiscussions {
            
            if !(alreadyPresentingSideNavigationController) {
                navigationController?.popViewController(animated: false)
            }
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
        presentedVC.discussionChatView.setReseivedMessageInfo(at: messageTimestamp, with: messageID, viewAnimated: viewAnimated)
    }
    
//    func updateUnreadMessageCount() {
//        logger.info("Updating count of unread messages")
//        
//        messagesReference.queryOrdered(byChild: DiscussionMessage.CodingKeys.messageTimestamp.stringValue).queryStarting(atValue: UserDefaults.standard.double(forKey: lastReadMessageTimestampKey)).observe(.value) { (snapshot) in
//            if let value = snapshot.value as? [String: Any] {
//                //                print("Number of unread messages: \(value.count) Last Read TS \(UserDefaults.standard.double(forKey: lastReadMessageTimestampKey))")
//                let unreadMessagesCount = value.count
//                (self.menuItems[.RECORDINGS]?.presentedVC as? MainVC)?.setUnreadMessagesCount(unreadMessagesCount: unreadMessagesCount)
//                (self.menuItems[.ABOUT]?.presentedVC as? InfoVC)?.setUnreadMessagesCount(unreadMessagesCount: unreadMessagesCount)
//            }
//        }
//    }
}

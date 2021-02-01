//
//  DiscussionsVCViewConfigurer.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension DiscussionsViewController {
    func addHeader() {
        
        let discussionsTitleLbl = UILabel()
        discussionsTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        discussionsTitleLbl.text = "Discussions"
        discussionsTitleLbl.textColor = .white
        discussionsTitleLbl.font = getFont(name: .HelveticaNeueBold, size: .xxlarge)
        
        let hamburgerBtn = UIButton()
        hamburgerBtn.translatesAutoresizingMaskIntoConstraints = false
        hamburgerBtn.setImage(sideNavIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        
        hamburgerBtn.tintColor = accentColor
        setBtnImgProp(button: hamburgerBtn, topPadding: 45/4, leftPadding: 5)
        hamburgerBtn.addTarget(self, action: #selector(displaySideNavTapped), for: .touchUpInside)
        hamburgerBtn.contentMode = .scaleAspectFit
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerBtn)
                
        userProfileButton.translatesAutoresizingMaskIntoConstraints = false
        userProfileButton.setImage(userPlaceholder.withRenderingMode(.alwaysOriginal), for: .normal)
        userProfileButton.imageView?.contentMode = .scaleAspectFit
        userProfileButton.addTarget(self, action: #selector(displayInfoTapped), for: .touchUpInside)
        userProfileButton.clipsToBounds = true
        userProfileButton.imageView?.layer.cornerRadius = 15
        userProfileButton.imageView?.layer.borderWidth = 1
        userProfileButton.imageView?.layer.borderColor = UIColor.white.cgColor
        userProfileButton.imageView?.clipsToBounds = true
        setBtnImgProp(button: userProfileButton, topPadding: 5, leftPadding: 5)

//        setUserProfileImage()
        
        let notificationsSettingButton = UIButton()
        notificationsSettingButton.translatesAutoresizingMaskIntoConstraints = false
        notificationsSettingButton.setImage(notificationBellIcon.withRenderingMode(.alwaysOriginal), for: .normal)
        notificationsSettingButton.imageView?.contentMode = .scaleAspectFit
        notificationsSettingButton.addTarget(self, action: #selector(showSettingsTapped), for: .touchUpInside)
        
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: notificationsSettingButton), UIBarButtonItem(customView: userProfileButton)]
        
    }
    
    func addCountryCountTableView() {
        countryCountView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countryCountView)
        
        NSLayoutConstraint.activate([
            countryCountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            countryCountView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countryCountView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            countryCountView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func addDiscussionsMessageBox() {
        view.addSubview(discussionsMessageBox)
        discussionsMessageBox.translatesAutoresizingMaskIntoConstraints = false
        
        
        discussionsMessageBoxBottomAnchor = discussionsMessageBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            discussionsMessageBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            discussionsMessageBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            discussionsMessageBoxBottomAnchor,
        ])
        
    }
    
    func addDiscussionChatView() {
        self.view.addSubview(discussionChatView)
        discussionChatView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            discussionChatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            discussionChatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            discussionChatView.topAnchor.constraint(equalTo: countryCountView.bottomAnchor  , constant: 10),
            discussionChatView.bottomAnchor.constraint(equalTo: discussionsMessageBox.topAnchor, constant: -10),
        ])
    }
}

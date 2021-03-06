//
//  InfoVC.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import GoogleSignIn

class InfoVC: UIViewController {
    
    //    static let infoVC = InfoVC()
    //    let sideNavVC = SideNavVC()
    
    //    @IBOutlet weak var displaySideNavBtn: UIButton!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var githubBtn: UIButton!
    @IBOutlet weak var gmailBtn: UIButton!
    @IBOutlet weak var twitterBtn: RoundButton!
    @IBOutlet weak var fABtn: UIButton!
    @IBOutlet weak var tTSBtn: UIButton!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var creditsTextView: UITextView!
    
    //    @IBOutlet weak var creditsTxtViewHeight: NSLayoutConstraint!
    
    //    let interactor = Interactor()
    
    let repoURL = URL(string: "https://github.com/parthv21/TOEFL-Speaking")
    
    let reportBugURL = URL(string: "googlegmail:///co?to=parthv21@gmail.com&subject=Bug%20Report%20(Speaking%20App)&body=Hey%20I%20found%20a%20bug!")
    
    let licenseURL = URL(string: "https://fontawesome.com/license")
    
    let ttsURL = URL(string: "http://www.fromtexttospeech.com")
    
    var icons = [boxIcon,infoIcon,emailIcon,shareIcon,checkIcon,closeIcon,githubIcon,deleteIcon,playBtnIcon,pauseBtnIcon,singleLeftIcon,doubleLeftIcon,tripleLeftIcon,doubleRightIcon,singleRightIcon,tripleRightIcon,plusIcon,minusIcon]
    
    var redIcons = [deleteIcon,closeIcon]
    
    var accentedIcons = [checkIcon,singleLeftIcon,singleRightIcon,doubleLeftIcon,doubleRightIcon,tripleLeftIcon,tripleRightIcon,infoIcon,sideNavIcon]
    
    var hamburgerBarButton: UIBarButtonItem?
    private var unreadMessagesCount: Int = 0 {
        didSet {
            logger.debug("Updating unread messages count \(unreadMessagesCount)")
            hamburgerBarButton?.setBadge(text: unreadMessagesCount == 0 ? nil : "\(unreadMessagesCount)")
        }
    }
    
    override func viewDidLoad() {
        logger.info("Loaded InfoVC view")

        super.viewDidLoad()
        
        setButtonProp()
        
        infoContainer.layer.cornerRadius = 5
        infoContainer.layer.masksToBounds = true
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        icons = icons.shuffled()
        
        fetchAndSetCredits()
        addHeader()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        logger.info("InfoVC view will appear")

        super.viewWillAppear(true)
        navigationController?.navigationBar.barTintColor = .black
        hamburgerBarButton?.setBadge(text: unreadMessagesCount == 0 ? nil : "\(unreadMessagesCount)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        hamburgerBarButton?.setBadge(text: unreadMessagesCount == 0 ? nil : "\(unreadMessagesCount)")
    }
    
    func setUnreadMessagesCount(unreadMessagesCount: Int) {
        self.unreadMessagesCount = unreadMessagesCount
    }
    
    func fetchAndSetCredits() {
        creditsReference.keepSynced(true)
        creditsReference.observe(.value, with: {(snapshot) in
            if let value = snapshot.value as? String {
                self.creditsTextView.text = value
                self.creditsTextView.scrollsToTop = true
                self.creditsTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
            }
        })
    }
    
    
    func addHeader() {
        logger.info("Configuring InfoVC header")

        title = "About"
        
        let hamburgerBtn = UIButton()
        hamburgerBtn.translatesAutoresizingMaskIntoConstraints = false
        hamburgerBtn.setImage(sideNavIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        
        hamburgerBtn.tintColor = accentColor
        setBtnImgProp(button: hamburgerBtn, topPadding: 45/4, leftPadding: 5)
        hamburgerBtn.addTarget(self, action: #selector(displaySideNavTapped), for: .touchUpInside)
        hamburgerBtn.contentMode = .scaleAspectFit
        
        hamburgerBarButton = UIBarButtonItem(customView: hamburgerBtn)
        navigationItem.leftBarButtonItem = hamburgerBarButton
        
    }
    
    
    @IBAction func displaySideNavTapped(_ sender: Any) {
        logger.event("Displaying side nav on tap in InfoVC")

        Analytics.logEvent(AnalyticsEvent.ShowSideNav.rawValue, parameters: nil)
        
        //        sideNavVC.transitioningDelegate = self
        //        sideNavVC.modalPresentationStyle = .custom
        //        sideNavVC.interactor = interactor
        //        sideNavVC.calledFromVC = InfoVC.infoVC
        //        self.present(sideNavVC, animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
    func setButtonProp() {
        logger.info("Setting InfoVC buttons prop")

        
        //        setBtnImgProp(button: displaySideNavBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        //        setButtonBgImage(button: displaySideNavBtn, bgImage: sideNavIcon, tintColor: accentColor)
        //        contactButton.setImage(buttonImage, for: .normal)
        
        //        setBtnImgProp(button: githubBtn, topPadding: 10, leftPadding: 1)
        setInfoButtonProps(button: githubBtn, image: githubIcon)
        githubBtn.backgroundColor = githubBlue.withAlphaComponent(0.8)
        
        //        setBtnImgProp(button: gmailBtn, topPadding: 10, leftPadding: 1)
        setInfoButtonProps(button: gmailBtn, image: emailIcon)
        gmailBtn.backgroundColor = disabledRed.withAlphaComponent(0.8)
        
        //        setBtnImgProp(button: twitterBtn, topPadding: 10, leftPadding: 1)
        setInfoButtonProps(button: twitterBtn, image: twitterIcon)
        twitterBtn.backgroundColor = twitterBlue.withAlphaComponent(0.8)
        
        fABtn.setTitleColor(accentColor, for: .normal)
        tTSBtn.setTitleColor(accentColor, for: .normal)
    }
    
    func setInfoButtonProps(button: UIButton, image: UIImage) {
        logger.info("Setting InfoVC button props")

        button.contentHorizontalAlignment = .center
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.titleLabel?.font = getFont(name: .HelveticaNeue, size: .large)
    }
    
    @IBAction func gitHubTapped(_ sender: UIButton) {
        logger.event("Opening github to raise an issue in github")

        Analytics.logEvent(AnalyticsEvent.OpenRepo.rawValue, parameters: nil)
        openURL(url: repoURL)
    }
    
    @IBAction func gmailTapped(_ sender: UIButton) {
        logger.event("Opening gmail to report bug to the developer")

        Analytics.logEvent(AnalyticsEvent.SendMail.rawValue, parameters: nil)
        openURL(url: reportBugURL)
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        logger.event("Opening twitter to request a feature")

        Analytics.logEvent(AnalyticsEvent.SendTweet.rawValue, parameters: nil)
        let screenName =  "parthv21"
        let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
        
        let application = UIApplication.shared
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    
    @IBAction func showLicenseTapped(_ sender: UIButton) {
        logger.event("Showing license")

        Analytics.logEvent(AnalyticsEvent.OpenFontAwesome.rawValue, parameters: nil)
        openURL(url: licenseURL)
    }
    
    @IBAction func fromTTSTapped(_ sender: UIButton) {
        logger.event("Opening TextToSpeech information website")

        Analytics.logEvent(AnalyticsEvent.OpenTextToSpeech.rawValue, parameters: nil)
        openURL(url: ttsURL)
    }
    
}

extension InfoVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCell {
            
            let cellImg = icons[indexPath.row]
            if accentedIcons.contains(cellImg) {
                cell.configureCell(icon: cellImg, tintColor: accentColor)
            } else if redIcons.contains(cellImg) {
                cell.configureCell(icon: cellImg, tintColor: enabledRed)
            } else {
                cell.configureCell(icon: icons[indexPath.row], tintColor: nil)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 40, height: 40)
    }
    
}

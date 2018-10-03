//
//  SideNavVC.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 28/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class SideNavVC: UIViewController{
    
    private let noticesUrl = "https://github.com/parthv21/Speech-Drill/blob/master/Speech-Drill/Information/info.json"
    
    private struct menuItem {
        let itemName: String
        let itemImg: UIImage
        let itemImgClr: UIColor
        let presentedVC: UIViewController
    }
    
    static let sideNav = SideNavVC()
    var interactor: Interactor? = nil
   
    var calledFromVC: UIViewController?
    
    private var sideNavWidth: CGFloat = 100
    private var hiddenSideNavWidth: CGFloat = 30
    
    
    private let updatesTextView = UITextView()
    private let menuTableView = UITableView()
    private var menuItems = [menuItem]()

    private var notices: Array<Dictionary<String,String>> = [[:]]
    private var noticeNumber = 0
    
    private let appstoreLink = "itms-apps://itunes.apple.com/app/id1433796147"
    private var phoneNumbers:[String:String] = ["Hvovi":"9987042606","Umang":"9167884007"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideNavWidth = view.bounds.width * MenuHelper.menuWidth
        hiddenSideNavWidth = view.bounds.width - sideNavWidth
        
        menuTableView.delegate = self
        menuTableView.dataSource = self

        populateMenuItems()
        fetchNotices()
        
        addViews()
        
        let closeBtn = UIButton(frame: CGRect(x: sideNavWidth, y: 0, width: hiddenSideNavWidth , height: view.bounds.height))
        closeBtn.addTarget(self, action: #selector(closeViewTapped), for: .touchUpInside)
        view.addSubview(closeBtn)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(closeViewWithPan(sender:)))
        view.addGestureRecognizer(panGesture)
        
        view.backgroundColor = MenuHelper.menuBGColor
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for (index,item) in menuItems.enumerated() {
            if item.presentedVC.isKind(of: type(of: calledFromVC!)) {
                let indexPath = IndexPath(item: index, section: 0)
                menuTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                break
            }
        }
    }
    
    func populateMenuItems() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
        
        let mainVCMenuItem = menuItem(itemName: "Recordings", itemImg: recordIcon, itemImgClr: disabledRed, presentedVC: mainVC)
        let infoVCMenuItem = menuItem(itemName: "Information", itemImg: infoIcon, itemImgClr: confirmGreen, presentedVC: infoVC)
        
        menuItems.append(mainVCMenuItem)
        menuItems.append(infoVCMenuItem)
    }
    
    func addViews() {
        
        var topMargin: CGFloat = 20
        var bottomMargin: CGFloat = -8
        
        let screenType = UIDevice.current.screenType
        if screenType == ScreenType.iPhoneXR || screenType == ScreenType.iPhoneXSMax || screenType == ScreenType.iPhoneX_iPhoneXS {
            topMargin = 30
            bottomMargin = -20
        }
        
        let noticeView = makeNoticeView()
        view.addSubview(noticeView)
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        let noticeViewHghtCnstrnt = NSLayoutConstraint(item: noticeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.bounds.height / 4)
        noticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        updatesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8 + hiddenSideNavWidth)).isActive = true
        noticeView.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin).isActive = true
        view.addConstraint(noticeViewHghtCnstrnt)
        
        let versionInfoView = makeVersionDetailView()
        view.addSubview(versionInfoView)
        versionInfoView.translatesAutoresizingMaskIntoConstraints = false
        let versionInfoViewTopCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .top, relatedBy: .equal, toItem: updatesTextView, attribute: .bottom, multiplier: 1, constant: 4)
        let versionInfoViewLeadingCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 8)
        let versionInfoViewTrailingCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -(8 + hiddenSideNavWidth))
        view.addConstraints([versionInfoViewTopCnstrnt,versionInfoViewLeadingCnstrnt,versionInfoViewTrailingCnstrnt])
    
        let adView = makeGoGeniusAdView()
        adView.layer.borderColor = UIColor.white.cgColor
        adView.layer.cornerRadius = 5
        adView.layer.borderWidth = 1
        adView.clipsToBounds = true
        
        view.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        adView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8+hiddenSideNavWidth)).isActive = true
        adView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomMargin).isActive = true
        
        menuTableView.allowsMultipleSelection = false
  
        view.addSubview(menuTableView)
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.backgroundColor = .clear
        menuTableView.topAnchor.constraint(equalTo: versionInfoView.bottomAnchor, constant: 20).isActive = true
        menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8+hiddenSideNavWidth)).isActive = true
        menuTableView.bottomAnchor.constraint(equalTo: adView.topAnchor, constant: 0).isActive = true

    }
    
    func makeNoticeView() -> UIView {
        let noticeContainer = UIView()
        
        let noticeStackView = UIStackView()
        noticeStackView.backgroundColor = .red
        noticeStackView.axis = .horizontal
        noticeStackView.spacing = 5
        noticeStackView.alignment = .fill
        noticeStackView.distribution = .fillEqually
        noticeContainer.addSubview(noticeStackView)
        noticeStackView.translatesAutoresizingMaskIntoConstraints = false
        noticeStackView.leadingAnchor.constraint(equalTo: noticeContainer.leadingAnchor).isActive = true
        noticeStackView.trailingAnchor.constraint(equalTo: noticeContainer.trailingAnchor).isActive = true
        noticeStackView.topAnchor.constraint(equalTo: noticeContainer.topAnchor).isActive = true
        let noticSVHeightCnstrnt = NSLayoutConstraint(item: noticeStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        noticeContainer.addConstraint(noticSVHeightCnstrnt)
        
        let nextNoticeBtn = UIButton()
        nextNoticeBtn.addTarget(self, action: #selector(showNextNotice), for: .touchUpInside)
        setButtonBgImage(button: nextNoticeBtn, bgImage: singleRightIcon, tintColor: .white)
        setBtnImgProp(button: nextNoticeBtn, topPadding: 5, leftPadding: 5)
        nextNoticeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let prevNoticeBtn = UIButton()
        prevNoticeBtn.addTarget(self, action: #selector(showPrevNotice), for: .touchUpInside)
        setButtonBgImage(button: prevNoticeBtn, bgImage: singleLeftIcon, tintColor: .white)
        setBtnImgProp(button: prevNoticeBtn, topPadding: 5, leftPadding: 5)
        prevNoticeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        noticeStackView.insertArrangedSubview(prevNoticeBtn, at: 0)
        noticeStackView.insertArrangedSubview(nextNoticeBtn, at: 1)
        
        let noticeLbl = UILabel()
        noticeLbl.text = "Notice"
        noticeLbl.textColor = .white
        noticeLbl.backgroundColor = .clear
        noticeLbl.textAlignment = .center
        noticeStackView.insertArrangedSubview(noticeLbl, at: 1)
        noticeLbl.translatesAutoresizingMaskIntoConstraints = false
        noticeLbl.topAnchor.constraint(equalTo: noticeStackView.topAnchor).isActive = true
        noticeLbl.bottomAnchor.constraint(equalTo: noticeStackView.bottomAnchor).isActive = true
        
        updatesTextView.isEditable = false
        updatesTextView.textColor = .white
        updatesTextView.backgroundColor = .clear
        updatesTextView.font = UIFont(name: "HelveticaNeue", size: 16)
        showNotice()
        
        updatesTextView.translatesAutoresizingMaskIntoConstraints = false
        noticeContainer.addSubview(updatesTextView)
        updatesTextView.leadingAnchor.constraint(equalTo: noticeContainer.leadingAnchor).isActive = true
        updatesTextView.trailingAnchor.constraint(equalTo: noticeContainer.trailingAnchor).isActive = true
        updatesTextView.topAnchor.constraint(equalTo: noticeStackView.bottomAnchor).isActive = true
        updatesTextView.bottomAnchor.constraint(equalTo: noticeContainer.bottomAnchor).isActive = true
        
        return noticeContainer
        
    }
    
    func makeVersionDetailView() -> UIView {
        
        let versionInfoLblHeight: CGFloat = 40
        let downloadBtnHeight: CGFloat = 40
        let downloadBtnWidth: CGFloat = 180
        
        let versionInfoView = UIView(frame: CGRect())
        
        let versionInfoLbl = UILabel()
        versionInfoView.addSubview(versionInfoLbl)
        versionInfoLbl.textAlignment = .center
        versionInfoLbl.numberOfLines = 0
        versionInfoLbl.textColor = UIColor.white
        versionInfoLbl.minimumScaleFactor = 0.5
        versionInfoLbl.translatesAutoresizingMaskIntoConstraints = false
        let versionInfoLblTopCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .top, relatedBy: .equal, toItem: versionInfoView, attribute: .top, multiplier: 1, constant: 0)
        let versionInfoLblLeadingCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .leading, relatedBy: .equal, toItem: versionInfoView, attribute: .leading, multiplier: 1, constant: 0)
        let versionInfoLblTrailingCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .trailing, relatedBy: .equal, toItem: versionInfoView, attribute: .trailing, multiplier: 1, constant: 0)
        let versionInfoLblHeightCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: versionInfoLblHeight)
    versionInfoView.addConstraints([versionInfoLblTopCnstrnt,versionInfoLblLeadingCnstrnt,versionInfoLblTrailingCnstrnt,versionInfoLblHeightCnstrnt])
        
        
        let appstoreBtn = UIButton(frame: CGRect())
        versionInfoView.addSubview(appstoreBtn)
        appstoreBtn.translatesAutoresizingMaskIntoConstraints = false
        appstoreBtn.addTarget(self, action: #selector(openInAppstore), for: .touchUpInside)
        appstoreBtn.layer.cornerRadius = 10
        appstoreBtn.clipsToBounds = true
        appstoreBtn.backgroundColor = enabledGray.withAlphaComponent(0.1)
        let appstoreBtnWidthCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: downloadBtnWidth)
        let appstoreBtnHightCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: downloadBtnHeight)
        let appstoreBtnCntrCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .centerX, relatedBy: .equal, toItem: versionInfoView, attribute: .centerX, multiplier: 1, constant: 0)
        let appstoreBtnTopCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .top, relatedBy: .equal, toItem: versionInfoLbl, attribute: .bottom, multiplier: 1, constant: 7)
       versionInfoView.addConstraints([appstoreBtnHightCnstrnt,appstoreBtnWidthCnstrnt,appstoreBtnCntrCnstrnt,appstoreBtnTopCnstrnt])
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = enabledGray
        versionInfoView.addSubview(seperatorView)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        let seperatorViewHeightCnstrnt = NSLayoutConstraint(item: seperatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
        let seperatorViewTopCnstrnt = NSLayoutConstraint(item: seperatorView, attribute: .top, relatedBy: .equal, toItem: appstoreBtn, attribute: .bottom, multiplier: 1, constant: 10)
        let seperatorViewBtmCnstrnt = NSLayoutConstraint(item:seperatorView , attribute: .bottom, relatedBy: .equal, toItem: versionInfoView , attribute: .bottom, multiplier: 1, constant: 0)
        seperatorView.leadingAnchor.constraint(equalTo: versionInfoView.leadingAnchor).isActive = true
        seperatorView.trailingAnchor.constraint(equalTo: versionInfoView.trailingAnchor).isActive = true
        versionInfoView.addConstraints([seperatorViewTopCnstrnt,seperatorViewHeightCnstrnt,seperatorViewBtmCnstrnt])
        
        var currentVersion = ""
        let currentBuildNo = getBuildNumber()
        var latestVersion = ""
        if let installedVersion = getInstalledVersion() {
            currentVersion = installedVersion
        }
        if let appstoreVersion = getAppstoreVersion() {
            latestVersion = appstoreVersion
        }
        
        var versionInfo = "You are running v\(currentVersion)"
        if currentBuildNo != "" {
            versionInfo += " (\(currentBuildNo))"
        }
        if currentVersion == latestVersion {
            appstoreBtn.setTitle("View on Appstore", for: .normal)
        } else {
            appstoreBtn.setTitle("Download (v\(latestVersion))", for: .normal)
        }
        versionInfoLbl.text = versionInfo
 
        return versionInfoView
    }
    
    func makeGoGeniusAdView() -> UIView {
        
        var goGeniusLogoHeight: CGFloat = 70
        var spacing: CGFloat = 8
        var callBtnHeight: CGFloat = 40
        
        let screenType = UIDevice.current.screenType.rawValue
        if  screenType == ScreenType.iPhones_5_5s_5c_SE.rawValue || screenType == ScreenType.iPhone4_4S.rawValue {
            goGeniusLogoHeight = 40
            spacing = 4
            callBtnHeight = 25
        }
        
        
        let adView = UIView()
        
        let adTapView = UIView()
        adView.addSubview(adTapView)
        adTapView.translatesAutoresizingMaskIntoConstraints = false
        adTapView.leadingAnchor.constraint(equalTo: adView.leadingAnchor).isActive = true
        adTapView.trailingAnchor.constraint(equalTo: adView.trailingAnchor).isActive = true
        adTapView.topAnchor.constraint(equalTo: adView.topAnchor).isActive = true
        
        let logoImgView = UIImageView(image: goGeniusLogo)
        adTapView.addSubview(logoImgView)
        logoImgView.translatesAutoresizingMaskIntoConstraints = false
        logoImgView.contentMode = .scaleAspectFit
        logoImgView.leadingAnchor.constraint(equalTo: adTapView.leadingAnchor,constant: 8).isActive = true
        logoImgView.trailingAnchor.constraint(equalTo: adTapView.trailingAnchor, constant: -8).isActive = true
        logoImgView.topAnchor.constraint(equalTo: adTapView.topAnchor, constant: spacing).isActive = true
        let logoImgViewHightCnstrnt = NSLayoutConstraint(item: logoImgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: goGeniusLogoHeight)
        adTapView.addConstraint(logoImgViewHightCnstrnt)
        
        let adLbl = UILabel()
        adLbl.text = "They are pretty awesome! :)"
        adLbl.font = UIFont(name: "HelveticaNeue", size: 15)
        adLbl.minimumScaleFactor = 0.5
        adLbl.textColor = .white
        adLbl.textAlignment = .center
        adTapView.addSubview(adLbl)
        adLbl.translatesAutoresizingMaskIntoConstraints = false
        adLbl.leadingAnchor.constraint(equalTo: adTapView.leadingAnchor).isActive = true
        adLbl.trailingAnchor.constraint(equalTo: adTapView.trailingAnchor).isActive = true
        adLbl.topAnchor.constraint(equalTo: logoImgView.bottomAnchor, constant: spacing).isActive = true
        adLbl.bottomAnchor.constraint(equalTo: adTapView.bottomAnchor).isActive = true
        let addLblHeightConstraint = NSLayoutConstraint(item: adLbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: callBtnHeight)
        adTapView.addConstraint(addLblHeightConstraint)
        
        let adTapGesture = UITapGestureRecognizer(target: self, action: #selector(openGoGeniusURL))
        adTapGesture.numberOfTapsRequired = 1
        adTapView.addGestureRecognizer(adTapGesture)
        adTapView.isUserInteractionEnabled = true
        
        let callHvoviBtn = makeCallBtn(name: "Hvovi")
        adView.addSubview(callHvoviBtn)
        callHvoviBtn.translatesAutoresizingMaskIntoConstraints = false
        callHvoviBtn.topAnchor.constraint(equalTo: adTapView.bottomAnchor, constant: spacing).isActive = true
        callHvoviBtn.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8).isActive = true
        callHvoviBtn.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8).isActive = true
        let callHvoviBtnHeightCnstrnt = NSLayoutConstraint(item: callHvoviBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: callBtnHeight)
        adView.addConstraint(callHvoviBtnHeightCnstrnt)
        
        let callUmangBtn = makeCallBtn(name: "Umang")
        adView.addSubview(callUmangBtn)
        callUmangBtn.translatesAutoresizingMaskIntoConstraints = false
        callUmangBtn.topAnchor.constraint(equalTo: callHvoviBtn.bottomAnchor, constant: 5).isActive = true
        callUmangBtn.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8).isActive = true
        callUmangBtn.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8).isActive = true
        callUmangBtn.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8).isActive = true
        let callUmangBtnHeightCnstrnt = NSLayoutConstraint(item: callUmangBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: callBtnHeight)
        adView.addConstraint(callUmangBtnHeightCnstrnt)
        
        return adView
        
    }
    
    func makeCallBtn(name: String) -> UIButton {
        let callBtn = UIButton()
        var textRightInset: CGFloat = 80
        var textLeftInset: CGFloat = 40
        var iconTopBottomInset: CGFloat = 10
        
        let screenType = UIDevice.current.screenType.rawValue
        if  screenType == ScreenType.iPhones_5_5s_5c_SE.rawValue || screenType == ScreenType.iPhone4_4S.rawValue {
            textRightInset = 60
            textLeftInset = 10
            iconTopBottomInset = 2
        }
        
        callBtn.backgroundColor = confirmGreen.withAlphaComponent(0.6)
        callBtn.layer.cornerRadius = 10
        callBtn.clipsToBounds = true
        
        callBtn.setTitle(name, for: .normal)
        
        let callImage = callIcon.withRenderingMode(.alwaysTemplate)
        callBtn.setImage(callImage, for: .normal)
        callBtn.tintColor = .white
        
        callBtn.imageView?.contentMode = .scaleAspectFit
        
        callBtn.imageEdgeInsets = UIEdgeInsets(top: iconTopBottomInset, left: 5, bottom:iconTopBottomInset, right: 70)
        callBtn.titleEdgeInsets = UIEdgeInsets(top: 5, left: textLeftInset, bottom: 5, right: textRightInset)
        callBtn.titleLabel?.textAlignment = .left
    
        callBtn.addTarget(self, action: #selector(callNumber(_:)), for: .touchUpInside)
        
        return callBtn
    }
    
    @objc func callNumber(_ sender: UIButton) {

        guard let name = sender.title(for: .normal) else { return }
        guard let number = phoneNumbers[name] else { return }
        
        Analytics.logEvent(AnalyticsEvent.CallCouncillor.rawValue, parameters: [StringAnalyticsProperties.CouncillorName.rawValue : name as NSObject])
        
        openURL(url: URL(string: "tel://\(number)"))
    }
    
    @objc func openGoGeniusURL(_ sender: UITapGestureRecognizer) {
        openURL(url: URL(string: "https://www.gogenius.co"))
    }
    
    @objc func showNextNotice() {
        if noticeNumber - 1 >= 0 {
          noticeNumber -= 1
        }
        showNotice()
    }
    
    @objc func showPrevNotice() {
        if noticeNumber + 1 < notices.count {
            noticeNumber += 1
        }
        showNotice()
    }
    
    func showNotice() {
        if noticeNumber >= 0 && noticeNumber < notices.count {
            
            guard let date = notices[noticeNumber]["date"],let notice = notices[noticeNumber]["notice"] else {
                    updatesTextView.text = "No notices..."
                    return
            }
            
            updatesTextView.text = "\(date)\n\n\(notice)"
            
        } else {
            updatesTextView.text = "No notices..."
        }
        
    }
    
    @objc func openInAppstore() {
        
        var currentVersion = "0"
        var latestVersion = "0"
        var isVersionSame: Int = 1
        
        if let cv = getInstalledVersion(), let lv = getAppstoreVersion() {
            currentVersion = cv
            latestVersion = lv
        }
        if currentVersion != latestVersion { isVersionSame = 0 }
        
        Analytics.logEvent(AnalyticsEvent.ViewOnAppstore.rawValue, parameters: [IntegerAnalyticsPropertites.ShowCurrentVersion.rawValue : isVersionSame as NSObject ])
        let url = URL(string: appstoreLink)
        openURL(url: url)
    }
    
    @objc func closeViewWithPan(sender: UIPanGestureRecognizer) {
        
        Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: calledFromVC))".lowercased()])
        
        let translation = sender.translation(in: view)
        let progress = MenuHelper.calculateProgress(
            translationInView: translation,
            viewBounds: view.bounds,
            direction: .Left
        )
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func closeViewTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchNotices() {
        
        let notesFIRBRef = Database.database().reference().child("notices")
        notesFIRBRef.keepSynced(true)
        notesFIRBRef.observe(.value) { (snapshot) in
            guard var notices = snapshot.value as? Array<Dictionary<String,String>> else { return }
            
            notices = notices.sorted(by: {(arg0,arg1) in
                guard let date1 = arg0["date"], let date2 = arg1["date"] else { return false}
                guard let dateObj1 = convertToDate(date: date1), let dateObj2 = convertToDate(date: date2) else { return false }
                return dateObj1 > dateObj2
            })
            self.notices = notices
            self.showNotice()
        }
    }
}

extension SideNavVC: UITableViewDelegate,UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellView = makeCellView(menuItem: menuItems[indexPath.row])
        cellView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cellView)
        cellView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        cellView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        cellView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        
        cell.backgroundColor = .clear
        let bgColorView = UIView()
        bgColorView.backgroundColor = disabledGray.withAlphaComponent(0.6)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcToPresent = menuItems[indexPath.row].presentedVC
        guard let calledFromVC = calledFromVC else { return }
        
        if vcToPresent.isKind(of: type(of: calledFromVC))  {
            
            Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: calledFromVC))".lowercased()])
            
            dismiss(animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                
                Analytics.logEvent(AnalyticsEvent.ChooseMenuItem.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: vcToPresent))".lowercased()])
                
                vcToPresent.transitioningDelegate = self
                vcToPresent.modalPresentationStyle = .custom
                self.present(vcToPresent, animated: true, completion: nil)
            }
        }
    }
    
    private func makeCellView(menuItem: menuItem) -> UIView {
        let cellView = UIView()

        let bgImage =  menuItem.itemImg.withRenderingMode(.alwaysTemplate)
        let cellIcon = UIImageView(image:bgImage)
        cellIcon.tintColor = menuItem.itemImgClr
        
        cellView.addSubview(cellIcon)
        cellIcon.translatesAutoresizingMaskIntoConstraints = false
        cellIcon.contentMode = .scaleAspectFit
        let cellIconLeadingCnstrnt = NSLayoutConstraint(item: cellIcon, attribute: .leading, relatedBy: .equal, toItem: cellView, attribute: .leading, multiplier: 1, constant: 0)
        let cellIconTopCnstrnt = NSLayoutConstraint(item: cellIcon, attribute: .top, relatedBy: .equal, toItem: cellView, attribute: .top, multiplier: 1, constant: 16)
        let cellIconBottomCnstrnt = NSLayoutConstraint(item: cellIcon, attribute: .bottom, relatedBy: .equal, toItem: cellView, attribute: .bottom, multiplier: 1, constant: -16)
        let cellIconWidthCnstrnt = NSLayoutConstraint(item: cellIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        cellView.addConstraints([cellIconTopCnstrnt,cellIconBottomCnstrnt,cellIconLeadingCnstrnt,cellIconWidthCnstrnt])
        
        let cellName = UILabel()
        cellName.text = menuItem.itemName
        cellName.textColor = .white
        cellName.textAlignment = .left
        
        cellView.addSubview(cellName)
        cellName.translatesAutoresizingMaskIntoConstraints = false
        cellName.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: 16).isActive = true
        cellName.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 8).isActive = true
        cellName.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -8).isActive = true
        cellName.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -8).isActive = true
        
        return cellView
    }
}

extension SideNavVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInVC()
    }
}

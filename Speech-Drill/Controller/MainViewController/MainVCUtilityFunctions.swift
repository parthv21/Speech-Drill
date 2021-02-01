//
//  MainVCUtilityFunctions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import FirebaseAnalytics

//MARK:- Utility Functions
extension MainVC {
    
    func countNumberOfRecordings() -> Int {
        let datedRecordingsCount = recordingUrlsDict.values.map { $0.count }
        let recordingsCount = datedRecordingsCount.reduce(0, { $0 + $1 })
        return recordingsCount
    }
    
    
    ///Update local list with newly added recording urls
    func updateUrlList() {
        
        recordingUrlsDict.removeAll()
        
        let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
        
        if let files = FileManager.default.enumerator(atPath: "\(documents)") {
            
            for file in files  {
                
                guard let fileUrl = URL(string: "\(file)") else { break }
                
                let recordingName = "\(file)"
                
                if recordingName.hasSuffix("."+recordingExtension) {
                    
                    if (recordingName != mergedFileName) {
                        
                        let timeStamp = splitFileURL(url: fileUrl).0
                        
                        let date = parseDate(timeStamp: timeStamp)
                        
                        let url = URL(fileURLWithPath: documents+"/"+"\(file)")
                        
                        var recordingURLs = recordingUrlsDict[date, default: [URL]()]
                        
                        //                        if recordingURLs == nil {
                        //                            recordingURLs = [URL]()
                        //                        }
                        
                        if (url == currentRecordingURL && !isRecording || url != currentRecordingURL){
                            recordingURLs.append(url)
                        }
                        
                        if (recordingURLs.count) > 0 {
                            recordingUrlsDict[date] = recordingURLs
                        }
                        
                    }
                }
            }
        }
        
        print("Number of recordings: ", countNumberOfRecordings())
        userDefaults.setValue(countNumberOfRecordings(), forKey: recordingsCountKey)
        saveCurrentNumberOfSavedRecordings()
    }
    
    ///Fetch a list of recordings urls for a day
    func getAudioFilesList(date: String) -> [URL] {
        return recordingUrlsDict[date, default: [URL]()]
    }
    
    func readTopics() {
        do{
            let fileURL = Bundle.main.url(forResource: "topics", withExtension: "csv")
            let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
            topics = content.components(separatedBy:"\n").map{$0}
        } catch {
            
        }
    }
    
    ///Increment current displayed topic number by 1
        func incrementTopicNumber() {
            topicNumber = min(topicNumber + 1, topics.count)
            //topicNumber + 1 < topics.count ? topicNumber + 1 : topicNumber
        }
    
    func renderTopic(topicNumber: Int) {
        var topicNumberToShow = 1
        if ( topicNumber > topics.count - 1) {
            topicNumberToShow = topics.count - 1
        } else {
            topicNumberToShow = topicNumber
        }
        userDefaults.set(topicNumberToShow, forKey: "topicNumber")
        self.topicNumber = topicNumberToShow
        topicTxtView.text = topics[topicNumberToShow]
        topicNumberLbl.text = "\(topicNumberToShow)"
    }
    
    
    func switchModes() {
        
        if checkIfRecordingIsOn() {return}
        
        title = isTestMode ? "Practice Mode" : "Test Mode"
        
        switchModeButton.setImage(isTestMode ? practiceModeIcon.withRenderingMode(.alwaysTemplate) : testModeIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        switchModeButton.tintColor = .white
        
        if isTestMode {
            
            Analytics.logEvent(AnalyticsEvent.ToggleSpeakingMode.rawValue, parameters: [StringAnalyticsProperties.ModeName.rawValue: "practice" as NSObject])
            
            UIView.animate(withDuration: 0.2) {
                self.thinkTimeChangeStackViewContainer.isHidden = true
            } completion: { (completed) in
                self.topicsContainer.isHidden = false
            }
            
            
            renderTopic(topicNumber: self.topicNumber)
            defaultThinkTime = 15
            defaultSpeakTime = 45
            thinkTime = defaultThinkTime
            speakTime = defaultSpeakTime
            
        } else {
            Analytics.logEvent(AnalyticsEvent.ToggleSpeakingMode.rawValue, parameters: [StringAnalyticsProperties.ModeName.rawValue: "test" as NSObject])
            
            
            UIView.animate(withDuration: 0.2) {
                self.thinkTimeChangeStackViewContainer.isHidden = false
                self.topicsContainer.isHidden = true
            }
            
            //            thinkTimeChangeStackViewSeperator.isHidden = false
            //            self.switchModesBtn.setTitle("Test", for: .normal)
            //            self.changeTopicBtnsStackView.isHidden = true
            //            self.topicTxtView.text = "TEST MODE"
        }
        isTestMode = !isTestMode
        resetRecordingState()
    }
    
    func setToTestMode() {
        isTestMode = false
        switchModes()
    }
    
    func setToPracticeMode() {
        isTestMode = true
        switchModes()
    }
    
}
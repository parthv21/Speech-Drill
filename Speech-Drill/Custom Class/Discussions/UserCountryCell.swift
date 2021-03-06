//
//  UserCountryCell.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 11/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class UserCountryCell: UICollectionViewCell {
    
    let countryNameLabel: UILabel
    let countryUserCountLabel: UILabel
    
    
    override init(frame: CGRect) {
        logger.info("Initializing user country cell")
        
        countryNameLabel = UILabel()
        countryUserCountLabel = UILabel()
        super.init(frame: frame)
        
        contentView.addSubview(countryNameLabel)
        countryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        countryNameLabel.font = getFont(name: .HelveticaNeueBold, size: .large)
        countryNameLabel.textColor = .white
        countryNameLabel.adjustsFontSizeToFitWidth = true
        countryNameLabel.minimumScaleFactor = 0.5
        //        countryNameLabel.numberOfLines = 1
        
        contentView.addSubview(countryUserCountLabel)
        countryUserCountLabel.translatesAutoresizingMaskIntoConstraints = false
        countryUserCountLabel.font = getFont(name: .HelveticaNeue, size: .medium)
        countryUserCountLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            countryNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            countryNameLabel.heightAnchor.constraint(equalToConstant: 50),
            countryNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            countryNameLabel.widthAnchor.constraint(equalToConstant: 30),
            //            countryNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            //            countryNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            //            countryNameLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            //            countryNameLabel.widthAnchor.constraint(equalToConstant: 20),
            
            countryUserCountLabel.leadingAnchor.constraint(equalTo: countryNameLabel.trailingAnchor, constant: 2),
            //            countryUserCountLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            //            countryUserCountLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            countryUserCountLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            countryUserCountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:0),
            countryUserCountLabel.heightAnchor.constraint(equalToConstant: 50),
            //            countryUserCountLabel.widthAnchor.constraint(equalToConstant: 40)
            //            countryUserCountLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(countryName: String, countryUserCount: Int) {
        logger.debug("Configuring country cell with \(countryName) and \(countryUserCount)")
        
        countryNameLabel.text = countryName
        countryUserCountLabel.text = String(countryUserCount)
    }
}

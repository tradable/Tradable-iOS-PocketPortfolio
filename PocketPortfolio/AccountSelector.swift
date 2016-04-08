//
//  AccountSelector.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 07/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class AccountSelector: UIView {    
    @IBOutlet weak var brokerLogo: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if accountList.count <= 1 {
            leftButton.hidden = true
            rightButton.hidden = true
        } else {
            leftButton.hidden = false
            rightButton.hidden = false
        }
    }
}
//
//  WatchlistCell.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

class WatchlistCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!

    @IBOutlet weak var askButton: UIButton!

    @IBOutlet weak var spreadLabel: UILabel!

    @IBOutlet weak var bidButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        askButton.layer.cornerRadius = 2
        askButton.layer.masksToBounds = true
        bidButton.layer.cornerRadius = 2
        bidButton.layer.masksToBounds = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            askButton.isHidden = true
            bidButton.isHidden = true
            spreadLabel.isHidden = true
        } else {
            askButton.isHidden = false
            bidButton.isHidden = false
            spreadLabel.isHidden = false
        }
    }
}

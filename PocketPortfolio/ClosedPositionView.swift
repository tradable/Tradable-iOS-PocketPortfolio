//
//  ClosedPositionView.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 27/11/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class ClosedPositionView: UIView {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let priceFormatter = NumberFormatter()
    let pnlFormatter = NumberFormatter()

    var instrument: TradableInstrument?
    var didRequestInstrument: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()

        priceFormatter.numberStyle = NumberFormatter.Style.decimal

        pnlFormatter.numberStyle = NumberFormatter.Style.decimal
        pnlFormatter.minimumFractionDigits = 2
        pnlFormatter.maximumFractionDigits = 2
        pnlFormatter.positivePrefix = pnlFormatter.plusSign
        pnlFormatter.negativePrefix = pnlFormatter.minusSign

        line.image = drawLine(color: whiteLineColor)

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
    }

    func updateClosedPosition(_ position: TradablePosition) {
        guard let instrument = instrument else {
            if !didRequestInstrument {
                didRequestInstrument = true
                position.getInstrument({ (instrument, _) in
                    self.instrument = instrument
                })
            }

            return
        }

        activityIndicator.stopAnimating()

        symbolLabel.text = instrument.brokerageAccountSymbol
        closedLabel.isHidden = false
        line.isHidden = false
    }
}

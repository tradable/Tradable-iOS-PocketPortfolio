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

    @IBOutlet weak var line: UIImageView!

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

        line.image = ClosedPositionView.drawWhiteLine()

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
    }

    func setPositionDetails(_ position: TradablePosition) {
        guard let instrument = instrument else {
            if !didRequestInstrument {
                didRequestInstrument = true
                position.getInstrument({ (instrument, _) in
                    self.instrument = instrument
                    self.symbolLabel.text = instrument?.brokerageAccountSymbol
                })
            }

            return
        }
        symbolLabel.text = instrument.brokerageAccountSymbol
    }

    class func drawWhiteLine() -> UIImage {
        let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        context?.setLineWidth(1.0)

        context?.beginPath()
        context?.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        context?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        context?.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

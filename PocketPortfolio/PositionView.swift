//
//  PositionView.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 08/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class PositionView: UIView {
    let greenColorTransparent = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 0.1).cgColor
    let pinkColorTransparent = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 191.0/255.0, alpha: 0.1).cgColor

    let greenColorSemiTransparent = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 0.5)
    let pinkColorSemiTransparent = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 0.5)

    @IBOutlet weak var symbolLabel: UILabel!

    @IBOutlet weak var pipsLabel: UILabel!

    @IBOutlet weak var pnlLabel: UILabel!

    @IBOutlet weak var directionLabel: UILabel!

    @IBOutlet weak var amountLabel: UILabel!

    @IBOutlet weak var atLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var tpLabel: UILabel!

    @IBOutlet weak var tpAmountLabel: UILabel!

    @IBOutlet weak var tpPipsLabel: UILabel!

    @IBOutlet weak var slLabel: UILabel!

    @IBOutlet weak var slAmountLabel: UILabel!

    @IBOutlet weak var slPipsLabel: UILabel!

    @IBOutlet weak var secondLine: UIImageView!

    @IBOutlet weak var firstLine: UIImageView!

    @IBOutlet weak var innerView: UIView!

    let gradient = CAGradientLayer()

    let amountFormatter = NumberFormatter()
    let priceFormatter = NumberFormatter()
    let pnlFormatter = NumberFormatter()

    var position: TradablePosition?

    var instrument: TradableInstrument?
    var didRequestInstrument: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()

        amountFormatter.numberStyle = NumberFormatter.Style.none
        amountFormatter.minimumIntegerDigits = 1
        amountFormatter.minimumFractionDigits = 0
        amountFormatter.maximumFractionDigits = 1
        amountFormatter.usesGroupingSeparator = true

        priceFormatter.numberStyle = NumberFormatter.Style.decimal

        pnlFormatter.numberStyle = NumberFormatter.Style.decimal
        pnlFormatter.minimumFractionDigits = 2
        pnlFormatter.maximumFractionDigits = 2
        pnlFormatter.positivePrefix = pnlFormatter.plusSign
        pnlFormatter.negativePrefix = pnlFormatter.minusSign

        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.locations = [0.67, 1.0]

        layer.insertSublayer(gradient, at: 0)

        firstLine.image = drawLine()
        secondLine.image = drawLine()

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradient.frame = self.bounds
        CATransaction.commit()
    }

    func updatePosition(_ position: TradablePosition) {
        self.position = position

        guard let instrument = instrument else {
            if !didRequestInstrument {
                didRequestInstrument = true
                position.getInstrument({ (instrument, _) in
                    self.instrument = instrument
                    self.symbolLabel.text = instrument?.brokerageAccountSymbol
                    self.atLabel.isHidden = false
                })
            }

            return
        }
        symbolLabel.text = instrument.brokerageAccountSymbol

        var hasProtections = false

        if let tp = position.takeProfit {
            do {
                let pipDistance = try TradableUtilities.getPipDistance(between: position.openPrice, and: tp, for: instrument)
                tpAmountLabel.text = "\(Int(abs(pipDistance.rounded(.toNearestOrAwayFromZero))))"
            } catch {
                tpAmountLabel.text = "-"
            }
            hasProtections = true
        } else if position.stopLoss != nil {
            tpAmountLabel.text = "-"
        }

        if let sl = position.stopLoss {
            do {
                let pipDistance = try TradableUtilities.getPipDistance(between: position.openPrice, and: sl, for: instrument)
                slAmountLabel.text = "\(Int(abs(pipDistance.rounded(.toNearestOrAwayFromZero))))"
            } catch {
                slAmountLabel.text = "-"
            }
            hasProtections = true
        } else if position.takeProfit != nil {
            slAmountLabel.text = "-"
        }

        if hasProtections {
            showProtections()
        } else {
            hideProtections()
        }

        if position.side == .buy {
            directionLabel.text = "\u{25B2} Long"
            directionLabel.textColor = greenColor
        } else if position.side == .sell {
            directionLabel.text = "\u{25BC} Short"
            directionLabel.textColor = darkPinkColor
        }

        amountLabel.text = amountFormatter.string(from: NSNumber(value: position.amount))

        let precision = instrument.pipPrecision
        var length = 2
        var toLast = 1
        if precision == 0 {
            toLast = 3
        } else if precision == 1 {
            length = 3
        }

        priceFormatter.minimumFractionDigits = precision == nil ? try! instrument.getPriceDecimals(forPrice: position.openPrice) : precision! + 1

        let priceStr = priceFormatter.string(from: NSNumber(value: position.openPrice))!

        let priceString = NSMutableAttributedString(string: priceStr)
        if precision != nil {
            priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0), range: NSRange(location: 0, length: priceString.length))
            priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: max(0, priceString.length - length - toLast), length: min(priceString.length, length + toLast)))
        } else {
            priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: priceString.length))
        }
        priceLabel.attributedText = priceString

        if !(instrument.type == .forex || instrument.type == .cfd) {
            pipsLabel.isHidden = true
        }

        if let openPnL = position.openProfit, let currentPrice = position.lastPrice {
            let positive = openPnL >= 0
            if positive {
                gradient.colors = [UIColor.clear.cgColor, greenColorTransparent]
                pipsLabel.textColor = greenColorSemiTransparent
                pnlLabel.textColor = greenColor
            } else {
                gradient.colors = [UIColor.clear.cgColor, pinkColorTransparent]
                pipsLabel.textColor = pinkColorSemiTransparent
                pnlLabel.textColor = darkPinkColor
            }
            pnlLabel.text = pnlFormatter.string(from: NSNumber(value: openPnL))

            do {
                let pipsPnL = try TradableUtilities.getProfitLossInPips(between: position.openPrice, and: currentPrice, for: instrument)
                pipsLabel.text = "(" + (positive ? "+" : "-") + "\(pipsPnL) pips)"
            } catch _ {
            }
        } else {
            gradient.colors = []
        }
    }

    func hideProtections() {
        secondLine.isHidden = true
        tpLabel.isHidden = true
        tpAmountLabel.isHidden = true
        tpPipsLabel.isHidden = true
        slLabel.isHidden = true
        slAmountLabel.isHidden = true
        slPipsLabel.isHidden = true

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
    }

    func showProtections() {
        secondLine.isHidden = false
        tpLabel.isHidden = false
        tpAmountLabel.isHidden = false
        tpPipsLabel.isHidden = false
        slLabel.isHidden = false
        slAmountLabel.isHidden = false
        slPipsLabel.isHidden = false

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 122.0)
    }
}

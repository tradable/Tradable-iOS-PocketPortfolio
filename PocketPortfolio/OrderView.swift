//
//  OrderView.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 08/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class OrderView: UIView {
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var orderSideLabel: UILabel!
    @IBOutlet weak var atLabel: UILabel!

    let amountFormatter = NumberFormatter()
    let priceFormatter = NumberFormatter()

    var order: TradableOrder?

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

        line.image = drawLine()

        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
    }

    func updateOrder(_ order: TradableOrder) {
        self.order = order

        guard let instrument = instrument else {
            if !didRequestInstrument {
                didRequestInstrument = true
                order.getInstrument({ (instrument, _) in
                    self.instrument = instrument
                    self.symbolLabel.text = instrument?.brokerageAccountSymbol
                    self.atLabel.isHidden = false
                })
            }

            return
        }
        symbolLabel.text = instrument.brokerageAccountSymbol

        if order.type == .limit {
            orderTypeLabel.text = "Limit Order"
        } else if order.type == .stop {
            orderTypeLabel.text = "Stop Order"
        } else {
            orderTypeLabel.text = "Pending Trade"
        }
        if order.side == .buy {
            orderSideLabel.text = "Buy"
            orderSideLabel.textColor = greenColor
        } else if order.side == .sell {
            orderSideLabel.text = "Sell"
            orderSideLabel.textColor = darkPinkColor
        }
        amountLabel.text = amountFormatter.string(from: NSNumber(value: order.amount))

        if order.price == 0 {
            priceLabel.attributedText = NSMutableAttributedString(string: "Market")
        } else {
            let precision = instrument.pipPrecision
            var length = 2
            var toLast = 1
            if precision == 0 {
                toLast = 3
            } else if precision == 1 {
                length = 3
            }

            priceFormatter.minimumFractionDigits = precision == nil ? try! instrument.getPriceDecimals(forPrice: order.price) : precision! + 1

            let priceStr = priceFormatter.string(from: NSNumber(value: order.price))!

            let priceString = NSMutableAttributedString(string: priceStr)
            if precision != nil {
                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0), range: NSRange(location: 0, length: priceString.length))
                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: max(0, priceString.length - length - toLast), length: min(priceString.length, length + toLast)))
            } else {
                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: priceString.length))
            }
            priceLabel.attributedText = priceString
        }
    }
}

//
//  ClosedPositionView.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 27/11/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class ClosedPositionView: UIView {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var closedPnLLabel: UILabel!
    @IBOutlet weak var closedPipsLabel: UILabel!
    
    @IBOutlet weak var line: UIImageView!
    
    let priceFormatter = NSNumberFormatter()
    let pnlFormatter = NSNumberFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        pnlFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        pnlFormatter.minimumFractionDigits = 2
        pnlFormatter.maximumFractionDigits = 2
        pnlFormatter.positivePrefix = pnlFormatter.plusSign
        pnlFormatter.negativePrefix = pnlFormatter.minusSign
        
        line.image = ClosedPositionView.drawWhiteLine()
        
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 81.0)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func setPositionDetail(position: TradablePosition) {
        symbolLabel.text = findBrokerageAccountSymbolForSymbol(position.symbol)
        
        if let closedPnl = position.closedProfit {
            let positive = closedPnl >= 0
            if positive {
                closedPnLLabel.textColor = greenColor
                closedPipsLabel.textColor = greenColor
            } else {
                closedPnLLabel.textColor = darkPinkColor
                closedPipsLabel.textColor = darkPinkColor
            }
            closedPnLLabel.text = pnlFormatter.stringFromNumber(closedPnl)
        }
    }
    
    
    class func drawWhiteLine() -> UIImage {
        let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor)
        CGContextSetLineWidth(context, 1.0)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
        CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
        CGContextStrokePath(context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

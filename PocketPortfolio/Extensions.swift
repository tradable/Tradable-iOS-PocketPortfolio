//
//  Extensions.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

let EPSILON:Double = 0.00000001

let greenCGColor = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 1.0).CGColor
let pinkCGColor = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 191.0/255.0, alpha: 1.0).CGColor

let greenColor = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 1.0)
let pinkColor = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 191.0/255.0, alpha: 1.0)
let darkPinkColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 1.0)

let customURI = "com.tradable.example1://oauth2callback"

let appID:UInt64 = 100007

let accountDidChangeNotificationKey = "com.tradable.pocketportfolio.accountDidChange"
let instrumentsDidChangeNotificationKey = "com.tradable.pocketportfolio.instrumentsDidChange"

var tradable:Tradable = Tradable.sharedInstance

let tradableSymbols = TradableSymbols()

let basicSymbols = ["EURUSD", "USDJPY", "AUDCAD", "EURGBP", "GBPUSD"]

var accountIndex:Int = 0

var accountList:TradableAccountList? {
    didSet {
        if let accountList = accountList {
            if !accountList.accounts.isEmpty {
                if accountIndex >= accountList.accounts.count {
                    accountIndex = accountList.accounts.count - 1
                } else if accountIndex < 0 {
                    accountIndex = 0
                }
                currentAccount = accountList.accounts[accountIndex]
            }
        }
    }
}

var currentAccount:TradableAccount? {
    didSet {
        tradable.getInstruments(currentAccount!) { (instruments, error) -> Void in
            instrumentList = instruments
        }
        instrumentsForSymbols = [:]
        symbolsForUpdates = []

        tradable.startUpdates(currentAccount!, updateType: .Full, frequency: .OneSecond, symbols: tradableSymbols)
        
        NSNotificationCenter.defaultCenter().postNotificationName(accountDidChangeNotificationKey, object: nil)
    }
}

var instrumentList:[TradableInstrument]? {
    didSet {
        NSNotificationCenter.defaultCenter().postNotificationName(instrumentsDidChangeNotificationKey, object: nil)
    }
}

var symbolsForUpdates:[String] = [] {
    didSet {
        tradableSymbols.symbols = symbolsForUpdates
        tradable.setSymbolsForUpdates(tradableSymbols)
    }
}

//managing temporary updates
var lastSymbolForTemporaryUpdates:String?

//removing last symbol for temporary updates
func removeSymbolForTemporaryUpdates() {
    if let symbolToRemove = lastSymbolForTemporaryUpdates {
        if let index = symbolsForUpdates.indexOf(symbolToRemove) {
            symbolsForUpdates.removeAtIndex(index)
        }
        lastSymbolForTemporaryUpdates = nil
    }
}

//adding selected symbol for temporary updates (from Trade View) to symbolsForUpdates list; removes last used symbol, if there was a different one
func addSymbolForTemporaryUpdates(symbol: String) {
    if let lastUsed = lastSymbolForTemporaryUpdates {
        if lastUsed != symbol {
            removeSymbolForTemporaryUpdates()
        }
    }
    lastSymbolForTemporaryUpdates = symbol
    symbolsForUpdates.append(symbol)
}

//reverse symbol mapping
var instrumentsForSymbols:[String:TradableInstrument] = [:]

func findBrokerageAccountSymbolForSymbol(symbol: String) -> String {
    if let instrumentForSymbol = instrumentsForSymbols[symbol] {
        return instrumentForSymbol.brokerageAccountSymbol
    }
    
    if let instruments = instrumentList {
        for instrument in instruments {
            if symbol.caseInsensitiveCompare(instrument.symbol) == .OrderedSame {
                instrumentsForSymbols[symbol] = instrument
                return instrument.brokerageAccountSymbol
            }
        }
    }
    
    return symbol
}

func findInstrumentForSymbol(symbol: String) -> TradableInstrument? {
    if let instrumentForSymbol = instrumentsForSymbols[symbol] {
        return instrumentForSymbol
    }
    
    if let instruments = instrumentList {
        for instrument in instruments {
            if symbol.caseInsensitiveCompare(instrument.symbol) == .OrderedSame {
                instrumentsForSymbols[symbol] = instrument
                return instrument
            }
        }
    }
    
    return nil
}

//calculating pips
func getPipDistance(from: Double, to: Double, instrument: TradableInstrument) -> Int {
    return Int(round((to - from) * pow(10.0, Double(instrument.pipPrecision))))
}

func getProfitLossInPips(openPrice: Double, currentPrice: Double, symbol: String) -> Int? {
    if let instrument = findInstrumentForSymbol(symbol) {
        let priceDifference = abs(currentPrice - openPrice)
        return Int(round(priceDifference * pow(10.0, Double(instrument.pipPrecision))))
    }
    return nil
}

func getPriceFromPipDistance(from: Double, distance: Double, instrument: TradableInstrument) -> Double {
    return from + distance * pow(10.0, -Double(instrument.pipPrecision))
}

//EXTENSIONS
extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIButton {
    func fadeUp() {
        self.layer.removeAllAnimations()
        self.backgroundColor = greenColor
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction.union(.CurveEaseOut), animations: { () -> Void in
            self.backgroundColor = UIColor.clearColor()
            }, completion: nil)
    }
    
    func fadeDown() {
        self.layer.removeAllAnimations()
        self.backgroundColor = pinkColor
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction.union(.CurveEaseOut), animations: { () -> Void in
            self.backgroundColor = UIColor.clearColor()
        }, completion: nil)
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed,bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
    func blink(completion: ((Bool) -> Void)?) {
        self.layer.removeAllAnimations()
        let color = self.backgroundColor
        self.backgroundColor = UIColor.redColor()
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.backgroundColor = color
        }, completion: completion)
    }
}

//global helper UI methods

func drawLine() -> UIImage {
    let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
    
    let context = UIGraphicsGetCurrentContext()
    CGContextSetStrokeColorWithColor(context, UIColor(red: 16.0/255.0, green: 137.0/255.0, blue: 147.0/255.0, alpha: 0.1).CGColor)
    CGContextSetLineWidth(context, 1.0)
    
    CGContextBeginPath(context)
    CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
    CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
    CGContextStrokePath(context)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
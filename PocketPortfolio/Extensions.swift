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

let tradableSymbols = TradableSymbols(symbols: [], includeMarginFactors: true)

let basicSymbols = ["EURUSD", "USDJPY", "AUDCAD", "EURGBP", "GBPUSD", "AAPL", "BABA", "BAC", "BIDU", "BRK.B", "FB", "GOOG", "KO", "MCD", "SAN"]

var accountIndex:Int = 0

var accountList:[TradableAccount] = [TradableAccount]()

func addAccount(account: TradableAccount) {
    var i = 0
    for _account in accountList {
        if _account.uniqueId == account.uniqueId {
            break
        }
        i += 1
    }
    if i == accountList.count {
        print("Account \(account.uniqueId) added.")
        accountList.append(account)
        
        accountIndex = accountList.count - 1
        
        currentAccount = accountList[accountIndex]
    }
}

func removeAccount(account: TradableAccount) {
    accountList = accountList.filter({
        $0.uniqueId != account.uniqueId
    })
    print("Account \(account.uniqueId) removed.")
    if accountList.count == 0 {
        currentAccount = nil
        tradable.createDemoAccount(TradableDemoAPIAuthenticationRequest(appId: appID, type: .FOREX), completion: { (accessToken, error) in
            if let accessToken = accessToken {
                tradable.activateAfterLaunchWithAccessToken(accessToken)
            }
        })
    } else {
        accountIndex = accountList.count - 1
        currentAccount = accountList[accountIndex]
    }

}

var currentAccount:TradableAccount? {
    willSet {
        if let ca = currentAccount {
            tradable.stopUpdates(ca)
        }
        instrumentsForSymbols = [:]
        symbolsForUpdates = []
    }
    didSet {
        if let ca = currentAccount {
            tradable.getInstruments(ca) { (instruments, error) -> Void in
                instrumentList = instruments
            }
            tradable.startUpdates(ca, updateType: .Full, frequency: .OneSecond, symbols: tradableSymbols)
            
            NSNotificationCenter.defaultCenter().postNotificationName(accountDidChangeNotificationKey, object: nil)
        }
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
        if let currentAccount = currentAccount {
            tradable.setSymbolsForUpdates(currentAccount, symbols: tradableSymbols)
        }
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
    var precision = instrument.pipPrecision
    if precision == nil {
        precision = instrument.decimals
    }
    return Int(round((to - from) * pow(10.0, Double(precision!))))
}

func getProfitLossInPips(openPrice: Double, currentPrice: Double, symbol: String) -> Int? {
    if let instrument = findInstrumentForSymbol(symbol) {
        let priceDifference = abs(currentPrice - openPrice)
        var precision = instrument.pipPrecision
        if precision == nil {
            precision = instrument.decimals
        }
        return Int(round(priceDifference * pow(10.0, Double(precision!))))
    }
    return nil
}

func getPriceFromPipDistance(from: Double, distance: Double, instrument: TradableInstrument) -> Double {
    var precision = instrument.pipPrecision
    if precision == nil {
        precision = instrument.decimals
    }
    return from + distance * pow(10.0, -Double(precision!))
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
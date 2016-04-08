//
//  WatchlistViewController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 05/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class WatchlistViewController: UITableViewController, TradableInstrumentSelectorDelegate {
    var symbols:[String] = [] {
        didSet {
            if canSave {
                saveWatchlist()
            }
        }
    }
    
    var pricesForSymbols:[String:(ask:Double?, bid:Double?, spread:Double?)] = [:]
    
    let numberFormatter = NSNumberFormatter()
    let priceFormatter = NSNumberFormatter()
    
    let fileManager = NSFileManager.defaultManager()
    
    var watchlistsFilePath = ""
    
    var canSave = false
    
    var canUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //read from file
        if let appSupportDirectory:String = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first {
            if !fileManager.fileExistsAtPath(appSupportDirectory) {
                do {
                    try fileManager.createDirectoryAtPath(appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Unable to create app support directory.")
                }
            }
            
            watchlistsFilePath = appSupportDirectory.stringByAppendingString("/watchlists.json")
            
            if !fileManager.fileExistsAtPath(watchlistsFilePath) {
                fileManager.createFileAtPath(watchlistsFilePath, contents: nil, attributes: nil)
            }
        }
        
        instrumentsChanged()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 1
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WatchlistViewController.instrumentsChanged), name: instrumentsDidChangeNotificationKey, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func saveWatchlist() {
        do {
            var contents = ["version" : "1.0" as AnyObject]
            
            var watchlists = [String:[String]]()
            
            let data = try String(contentsOfFile: watchlistsFilePath)
            if let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding) {
                let jsonRead = JSON(data: jsonData)
                if let watchlistsRead = jsonRead["watchlists"].array {
                    for watchlistRead in watchlistsRead {
                        for (key, value) in watchlistRead.dictionaryValue {
                            watchlists[key] = value.arrayValue.map{ $0.stringValue }
                        }
                    }
                }
            }
            
            watchlists[currentAccount!.uniqueId] = symbols
            
            contents["watchlists"] = [watchlists]
            
            let json = JSON(contents)
            
            try json.rawString()!.writeToFile(watchlistsFilePath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            print("Unable to write to file.")
        }
    }
    
    func loadWatchlist() {
        symbols = []
        do {
            let data = try String(contentsOfFile: watchlistsFilePath)
            if let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding) {
                let jsonRead = JSON(data: jsonData)
                if let watchlistsRead = jsonRead["watchlists"].array {
                    for watchlistRead in watchlistsRead {
                        for (key, value) in watchlistRead.dictionaryValue {
                            if key == currentAccount!.uniqueId {
                                symbols = value.arrayValue.map{ $0.stringValue }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Unable to open file.")
        }
        
        canSave = true
    }
    
    func instrumentsChanged() {
        canUpdate = false
        canSave = false
        
        loadWatchlist()
        
        var tempSymbols = [String]()
        
        if let instrumentList = instrumentList {
            for instrument in instrumentList {
                if symbols.isEmpty {
                    if basicSymbols.contains(instrument.symbol) {
                        symbolsForUpdates.append(instrument.symbol)
                        tempSymbols.append(instrument.symbol)
                    }
                } else {
                    if symbols.contains(instrument.symbol) {
                        symbolsForUpdates.append(instrument.symbol)
                    }
                }
            }
        }
        
        if symbols.isEmpty {
            symbols = tempSymbols
        }
        
        tableView.reloadData()
        canUpdate = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistCell", forIndexPath: indexPath) as! WatchlistCell
        
        let symbol = symbols[indexPath.row]
        
        cell.symbolLabel.text = findBrokerageAccountSymbolForSymbol(symbol)
        
        cell.askButton.addTarget(self, action: #selector(WatchlistViewController.showTradeView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.askButton.tag = indexPath.row * 2
        cell.bidButton.addTarget(self, action: #selector(WatchlistViewController.showTradeView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.bidButton.tag = indexPath.row * 2 + 1
        
        cell.askButton.setAttributedTitle(NSAttributedString(string: "..."), forState: UIControlState.Normal)
        cell.spreadLabel.text = "..."
        cell.bidButton.setAttributedTitle(NSAttributedString(string: "..."), forState: UIControlState.Normal)
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            pricesForSymbols[symbols[indexPath.row]] = nil
            symbols.removeAtIndex(indexPath.row)
            symbolsForUpdates = symbols
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = symbols[fromIndexPath.row]
        symbols.removeAtIndex(fromIndexPath.row)
        symbols.insert(itemToMove, atIndex: toIndexPath.row)
    }
    
    func tradableInstrumentSelectorDismissed(instrument: TradableInstrument?) {
        if let instrument = instrument {
            let newIndexPath = NSIndexPath(forRow: symbols.count, inSection: 0)
            symbols.append(instrument.symbol)
            symbolsForUpdates = symbols
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
        }
    }
    
    func showTradeView(sender: UIButton) {
        if !tableView.editing {
            let symbol = (sender.superview!.superview! as! WatchlistCell).symbolLabel.text!
            let side:TradableOrderSide = sender.tag % 2 == 0 ? .BUY : .SELL
            
            tradable.presentOrderEntry(currentAccount!, symbol: symbol, side: side, delegate: self.navigationController as! WatchlistNavController, presentingViewController: self.navigationController!, presentationStyle: UIModalPresentationStyle.OverCurrentContext)
            (self.navigationController!.tabBarController as! TabBarController).selectMiddleButton()
        }
    }
    
    func updateData() {
        if canUpdate {
            if let indexPaths = tableView?.indexPathsForVisibleRows {
                for indexPath in indexPaths {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! WatchlistCell
                    
                    let symbol = symbols[indexPath.row]
                    
                    if let instrument = findInstrumentForSymbol(symbol) {
                        
                        priceFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                        priceFormatter.minimumFractionDigits = instrument.pipPrecision == nil ? instrument.decimals : instrument.pipPrecision! + 1
                        
                        let precision = instrument.pipPrecision == nil ? 0 : instrument.pipPrecision! + 1
                        
                        var length = 2
                        var toLast = 1
                        if precision == 0 {
                            toLast = 3
                        } else if precision == 1 {
                            length = 3
                        }
                        
                        if let ask = pricesForSymbols[symbol]?.ask {
                            let askButton = cell.askButton
                            if let prevAskText = askButton.titleLabel!.text {
                                if let prevAsk = priceFormatter.numberFromString(prevAskText)?.doubleValue {
                                    if prevAsk - ask > EPSILON {
                                        askButton.fadeDown()
                                    } else if ask - prevAsk > EPSILON {
                                        askButton.fadeUp()
                                    }
                                }
                            }
                            let priceStr = priceFormatter.stringFromNumber(ask)!
                            
                            let priceString = NSMutableAttributedString(string: priceStr)
                            if instrument.pipPrecision != nil {
                                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5), range: NSRange(location: 0, length: priceString.length))
                                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: priceString.length - length - toLast, length: length + toLast))
                            } else {
                                 priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: priceString.length))
                            }
                            askButton.setAttributedTitle(priceString, forState: UIControlState.Normal)
                        }
                        
                        if let bid = pricesForSymbols[symbol]?.bid {
                            let bidButton = cell.bidButton
                            if let prevBidText = bidButton.titleLabel!.text  {
                                if let prevBid = priceFormatter.numberFromString(prevBidText)?.doubleValue {
                                    if prevBid - bid > EPSILON {
                                        bidButton.fadeDown()
                                    } else if bid - prevBid > EPSILON {
                                        bidButton.fadeUp()
                                    }
                                }
                            }
                            let priceStr = priceFormatter.stringFromNumber(bid)!
                            
                            let priceString = NSMutableAttributedString(string: priceStr)
                            if instrument.pipPrecision != nil {
                                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5), range: NSRange(location: 0, length: priceString.length))
                                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: priceString.length - length - toLast, length: length + toLast))
                            } else {
                                priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: priceString.length))
                            }
                            bidButton.setAttributedTitle(priceString, forState: UIControlState.Normal)
                        }
                        
                        if let spread = pricesForSymbols[symbol]?.spread {
                            cell.spreadLabel.text = numberFormatter.stringFromNumber(spread)
                        }
                        
                    }
                    cell.backgroundColor = UIColor.clearColor()
                }
            }
        }
    }
    
    @IBAction func addSymbolTap(sender: UIBarButtonItem) {
        tradable.presentInstrumentSelector(currentAccount!, delegate: self, presentingViewController: self, presentationStyle: UIModalPresentationStyle.OverFullScreen)
    }
}
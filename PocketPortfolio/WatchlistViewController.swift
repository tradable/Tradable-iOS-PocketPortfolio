//
//  WatchlistViewController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 05/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

import SwiftyJSON

class WatchlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TradableInstrumentSelectorDelegate {

    @IBOutlet weak var addInstrumentsLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var instrumentIds: [String] = []
    var pricesForInstrumentIds: [String: TradablePrice] = [:]

    let numberFormatter = NumberFormatter()
    let askPriceFormatter = NumberFormatter()
    let bidPriceFormatter = NumberFormatter()

    let fileManager = FileManager.default

    var watchlistsFilePath = ""

    var canSave = false

    var canUpdate = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        checkOrCreateWatchlistFile()

        accountChanged()

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 1

        askPriceFormatter.numberStyle = NumberFormatter.Style.decimal
        bidPriceFormatter.numberStyle = NumberFormatter.Style.decimal

        NotificationCenter.default.addObserver(self, selector: #selector(WatchlistViewController.accountChanged), name: NSNotification.Name(rawValue: accountDidChangeNotificationKey), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func checkOrCreateWatchlistFile() {
        guard let appSupportDirectory: String = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else { return }

        if !fileManager.fileExists(atPath: appSupportDirectory) {
            do {
                try fileManager.createDirectory(atPath: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Unable to create app support directory.")
            }
        }

        watchlistsFilePath = appSupportDirectory + "/watchlists.json"

        if !fileManager.fileExists(atPath: watchlistsFilePath) {
            fileManager.createFile(atPath: watchlistsFilePath, contents: nil, attributes: nil)
        }
    }

    func saveWatchlist() {
        guard canSave else { return }
        do {
            var contents: [String: Any] = ["version": "2.0"]

            var watchlists = [String: [String]]()

            let data = try String(contentsOfFile: watchlistsFilePath)
            if let jsonData = data.data(using: String.Encoding.utf8) {
                let jsonRead = JSON(data: jsonData)
                if let watchlistsRead = jsonRead["watchlists"].array {
                    for watchlistRead in watchlistsRead {
                        for (key, value) in watchlistRead.dictionaryValue {
                            watchlists[key] = value.arrayValue.map { $0.stringValue }
                        }
                    }
                }
            }

            watchlists[currentAccount!.id] = instrumentIds

            contents["watchlists"] = [watchlists]

            let json = JSON(contents)

            try json.rawString()!.write(toFile: watchlistsFilePath, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("Unable to write to file.")
        }
    }

    func loadWatchlist() -> [String] {
        var loadedInstrumentIds: [String] = []
        do {
            let data = try String(contentsOfFile: watchlistsFilePath)
            if let jsonData = data.data(using: String.Encoding.utf8) {
                let jsonRead = JSON(data: jsonData)
                if jsonRead["version"] == "2.0" {
                    if let watchlistsRead = jsonRead["watchlists"].array {
                        for watchlistRead in watchlistsRead {
                            loadedInstrumentIds = watchlistRead[currentAccount!.id].arrayValue.map { $0.stringValue }
                        }
                    }
                }
            }
        } catch {
            print("Unable to open file.")
        }

        canSave = true

        return loadedInstrumentIds
    }

    func accountChanged() {
        //figure out how to prevent from crashing when acc changes too fast
        canUpdate = false
        canSave = false

        instrumentIds = []
        pricesForInstrumentIds = [:]

        let loadedInstrumentIds = loadWatchlist()
        print(loadedInstrumentIds)

        if loadedInstrumentIds.isEmpty {
            addInstrumentsLabel.isHidden = false
        } else {
            addInstrumentsLabel.isHidden = true
            instrumentIds = loadedInstrumentIds
            instrumentIdsForUpdates = instrumentIds
            currentAccount!.getInstruments(with: TradableInstrumentSearchRequest(instrumentIds: loadedInstrumentIds), completionHandler: { (instrumentList, _) in
                guard let instrumentList = instrumentList else { return }
                var index = 0
                for instrument in instrumentList.instruments {
                    cachedInstruments[instrument.id] = instrument
                    (self.tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as! WatchlistCell).symbolLabel.text = instrument.brokerageAccountSymbol
                    index += 1
                }
            })
        }

        canUpdate = true
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instrumentIds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchlistCell", for: indexPath) as! WatchlistCell

        let instrumentId = instrumentIds[indexPath.row]

        cell.symbolLabel.text = cachedInstruments[instrumentId]?.brokerageAccountSymbol

        cell.askButton.addTarget(self, action: #selector(WatchlistViewController.showTradeView(_:)), for: UIControlEvents.touchUpInside)
        cell.askButton.tag = indexPath.row * 2
        cell.bidButton.addTarget(self, action: #selector(WatchlistViewController.showTradeView(_:)), for: UIControlEvents.touchUpInside)
        cell.bidButton.tag = indexPath.row * 2 + 1

        cell.askButton.setAttributedTitle(NSAttributedString(string: "..."), for: UIControlState())
        cell.spreadLabel.text = "..."
        cell.bidButton.setAttributedTitle(NSAttributedString(string: "..."), for: UIControlState())

        cell.backgroundColor = UIColor.clear

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //do not remove instrument, leave it cached in case user adds it again or has more than one entry for this instrument id
            instrumentIds.remove(at: indexPath.row)
            saveWatchlist()
            instrumentIdsForUpdates = instrumentIds
            tableView.deleteRows(at: [indexPath], with: .fade)
            if instrumentIds.isEmpty {
                addInstrumentsLabel.isHidden = false
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let itemToMove = instrumentIds[fromIndexPath.row]
        instrumentIds.remove(at: fromIndexPath.row)
        instrumentIds.insert(itemToMove, at: toIndexPath.row)
        saveWatchlist()
    }

    func tradableInstrumentSelectorDismissed(instrumentSearchResult: TradableInstrumentSearchResult?) {
        if let instrumentSearchResult = instrumentSearchResult {
            let newIndexPath = IndexPath(row: instrumentIds.count, section: 0)
            instrumentIds.append(instrumentSearchResult.instrumentId)
            saveWatchlist()
            instrumentIdsForUpdates = instrumentIds
            addInstrumentsLabel.isHidden = true
            currentAccount!.getInstruments(with: TradableInstrumentSearchRequest(instrumentIds: [instrumentSearchResult.instrumentId]), completionHandler: { (instrumentList, _) in
                self.tableView?.insertRows(at: [newIndexPath], with: .bottom)
                cachedInstruments[instrumentSearchResult.instrumentId] = instrumentList?.instruments.first
                (self.tableView?.cellForRow(at: newIndexPath) as! WatchlistCell).symbolLabel.text = instrumentList?.instruments.first?.brokerageAccountSymbol
            })
        }
    }

    func showTradeView(_ sender: UIButton) {
        if !tableView.isEditing {
            let instrumentId = instrumentIds[(tableView.indexPath(for: sender.superview!.superview! as! WatchlistCell)!.row)]
            let side: TradableOrderSide = sender.tag % 2 == 0 ? .buy : .sell

           self.tradablePresentOrderEntry(for: currentAccount!, with: cachedInstruments[instrumentId], withSide: side, delegate: self.navigationController as! WatchlistNavController, presentationStyle: UIModalPresentationStyle.overCurrentContext)
            (self.navigationController!.tabBarController as! TabBarController).selectMiddleButton()
        }
    }

    func updateData() {
        if canUpdate {
            guard let indexPaths = tableView?.indexPathsForVisibleRows else { return }

            for indexPath in indexPaths {
                let cell = tableView.cellForRow(at: indexPath) as! WatchlistCell

                defer { cell.backgroundColor = UIColor.clear }

                let instrumentId = instrumentIds[indexPath.row]

                guard let instrument = cachedInstruments[instrumentId] else { return }

                let precision = instrument.pipPrecision

                var length = 2
                var toLast = 1
                if precision == 0 {
                    toLast = 3
                } else if precision == 1 {
                    length = 3
                }

                if let ask = pricesForInstrumentIds[instrumentId]?.ask {
                    askPriceFormatter.minimumFractionDigits = precision == nil ? try! instrument.getPriceDecimals(forPrice: ask) : precision! + 1

                    let askButton = cell.askButton!
                    if let prevAskText = askButton.titleLabel!.text {
                        if let prevAsk = askPriceFormatter.number(from: prevAskText)?.doubleValue {
                            if prevAsk - ask > EPSILON {
                                askButton.fadePink()
                            } else if ask - prevAsk > EPSILON {
                                askButton.fadeGreen()
                            }
                        }
                    }
                    let priceStr = askPriceFormatter.string(from: NSNumber(value: ask))!

                    let priceString = NSMutableAttributedString(string: priceStr)
                    if instrument.pipPrecision != nil {
                        priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5), range: NSRange(location: 0, length: priceString.length))
                        priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: max(0, priceString.length - length - toLast), length: min(priceString.length, length + toLast)))
                    } else {
                        priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: priceString.length))
                    }
                    askButton.setAttributedTitle(priceString, for: UIControlState())
                }

                if let bid = pricesForInstrumentIds[instrumentId]?.bid {
                    bidPriceFormatter.minimumFractionDigits = precision == nil ? try! instrument.getPriceDecimals(forPrice: bid) : precision! + 1

                    let bidButton = cell.bidButton!
                    if let prevBidText = bidButton.titleLabel!.text {
                        if let prevBid = askPriceFormatter.number(from: prevBidText)?.doubleValue {
                            if prevBid - bid > EPSILON {
                                bidButton.fadePink()
                            } else if bid - prevBid > EPSILON {
                                bidButton.fadeGreen()
                            }
                        }
                    }
                    let priceStr = bidPriceFormatter.string(from: NSNumber(value: bid))!

                    let priceString = NSMutableAttributedString(string: priceStr)
                    if instrument.pipPrecision != nil {
                        priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5), range: NSRange(location: 0, length: priceString.length))
                        priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: max(0, priceString.length - length - toLast), length: min(priceString.length, length + toLast)))
                    } else {
                        priceString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: priceString.length))
                    }
                    bidButton.setAttributedTitle(priceString, for: UIControlState())
                }

                if let spread = pricesForInstrumentIds[instrumentId]?.spread {
                    cell.spreadLabel.text = numberFormatter.string(from: NSNumber(value: spread))
                }
            }
        }
    }

    @IBAction func addSymbolTap(_ sender: UIBarButtonItem) {
        self.tradablePresentInstrumentSelector(for: currentAccount!, delegate: self, presentationStyle: UIModalPresentationStyle.overFullScreen)
    }
}

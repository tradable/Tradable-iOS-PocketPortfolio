//
//  AccountViewController.swift
//  TradableExampleApp
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var accountSelector: AccountSelector!
    
    @IBOutlet weak var tableView: UITableView!
    
    var currency:String?
    var balance:Double?
    var equity:Double?
    var openPnL:Double?
    var marginAmountUsed:Double?
    
    let cells = ["Currency", "Balance", "Equity", "Open PnL", "Margin used"]
    
    let numberFormatterCurrency = NSNumberFormatter()
    let numberFormatterPercent = NSNumberFormatter()
    
    var canSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatterCurrency.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatterCurrency.currencySymbol = ""
        
        numberFormatterPercent.numberStyle = NSNumberFormatterStyle.PercentStyle
        numberFormatterPercent.maximumFractionDigits = 1
        numberFormatterPercent.minimumFractionDigits = 1
        
        accountChanged()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountViewController.accountChanged), name: accountDidChangeNotificationKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("accountCell", forIndexPath: indexPath) as! AccountCell
        
        cell.titleLabel?.text = cells[indexPath.row]
        
        if indexPath.row == 3 {
            cell.valueLabel.font = UIFont(name: "HelveticaNeue", size: 24.0)
        }
        
        if indexPath.row == 0 {
            cell.valueLabel.text = currency
        } else if indexPath.row == 1 {
            if let balance = balance {
                cell.valueLabel.text = numberFormatterCurrency.stringFromNumber(balance)
            } else {
                cell.valueLabel.text = "..."
            }
        } else if indexPath.row == 2 {
            if let equity = equity {
                cell.valueLabel.text = numberFormatterCurrency.stringFromNumber(equity)
            } else {
                cell.valueLabel.text = "..."
            }
        } else if indexPath.row == 3 {
            if let openPnL = openPnL {
                cell.valueLabel.textColor = openPnL >= 0 ? greenColor : pinkColor
                cell.valueLabel.text = numberFormatterCurrency.stringFromNumber(openPnL)
            } else {
                cell.valueLabel.textColor = UIColor.blackColor()
                cell.valueLabel.text = "..."
            }
        } else if indexPath.row == 4 {
            if let marginAmountUsed = marginAmountUsed, equity = equity {
                cell.valueLabel.text = numberFormatterPercent.stringFromNumber(marginAmountUsed/equity)
            } else {
                cell.valueLabel.text = "..."
            }
        }
    
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    @IBAction func nextAccountTap(sender: UIButton) {
        changeToNextAccount()
    }
    
    @IBAction func previousAccountTap(sender: UIButton) {
        changeToPrevAccount()
    }

    @IBAction func rightSwipe(sender: UISwipeGestureRecognizer) {
        changeToPrevAccount()
    }
    
    @IBAction func leftSwipe(sender: UISwipeGestureRecognizer) {
        changeToNextAccount()
    }
    
    func clearData() {
        if (accountList.count > 1) {
            accountSelector.accountLabel.text = nil
            accountSelector.brokerLogo.image = nil
            
            currency = nil
            balance = nil
            marginAmountUsed = nil
            equity = nil
            openPnL = nil
            updateData()
            canSwitch = false
        }
    }
    
    func changeToPrevAccount() {
        if canSwitch {
            clearData()
            let idx = (accountIndex - 1) % accountList.count
            accountIndex = idx >= 0 ? idx : accountList.count + idx
            currentAccount = accountList[accountIndex]
        }
    }
    
    func changeToNextAccount() {
        if canSwitch {
            clearData()
            accountIndex = (accountIndex + 1) % accountList.count
            currentAccount = accountList[accountIndex]
        }
    }
    
    func accountChanged() {
        print("Account changed.")
        
        if accountList.count > 1 {
            accountSelector.rightButton.hidden = false
            accountSelector.leftButton.hidden = false
        } else {
            accountSelector.rightButton.hidden = true
            accountSelector.leftButton.hidden = true
        }
        
        if let currentAccount = currentAccount {
            
            accountSelector.accountLabel.text = currentAccount.displayName
            currentAccount.brokerLogos.getLightBrokerLogo({ (logoImg) -> Void in
                self.accountSelector.brokerLogo.image = logoImg
            })
            
            currency = currentAccount.currencyIsoCode
            updateData()
            canSwitch = true
        }
    }
    
    func updateData() {
        if let indexPaths = tableView?.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                let cell = tableView?.cellForRowAtIndexPath(indexPath) as! AccountCell
                
                if indexPath.row == 0 {
                    cell.valueLabel.text = currency
                } else if indexPath.row == 1 {
                    if let balance = balance {
                        cell.valueLabel.text = numberFormatterCurrency.stringFromNumber(balance)
                    } else {
                        cell.valueLabel.text = "..."
                    }
                } else if indexPath.row == 2 {
                    if let equity = equity {
                        cell.valueLabel.text = numberFormatterCurrency.stringFromNumber(equity)
                    } else {
                        cell.valueLabel.text = "..."
                    }
                } else if indexPath.row == 3 {
                    if let openPnL = openPnL {
                        cell.valueLabel.textColor = openPnL >= 0 ? greenColor : pinkColor
                        cell.valueLabel.text = numberFormatterCurrency.stringFromNumber(openPnL)
                    } else {
                        cell.valueLabel.textColor = UIColor.blackColor()
                        cell.valueLabel.text = "..."
                    }
                } else if indexPath.row == 4 {
                    if let marginUse = marginAmountUsed, equity = equity {
                        cell.valueLabel.text = numberFormatterPercent.stringFromNumber(marginUse/equity)
                    } else {
                        cell.valueLabel.text = "..."
                    }
                }
            }
        }
    }
    
    @IBAction func addAccountTap(sender: UIButton) {
        tradable.authenticateWithAppIdAndUri(appID, uri: customURI, webView: nil)
    }
}
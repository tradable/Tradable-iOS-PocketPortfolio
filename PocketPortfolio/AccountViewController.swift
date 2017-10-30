//
//  AccountViewController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit
import SafariServices

import TradableAPI

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {

    @IBOutlet weak var accountSelector: AccountSelector!

    @IBOutlet weak var tableView: UITableView!

    var metrics: TradableAccountMetrics?

    var currency: String?

    let cellTexts = ["Currency", "Balance", "Equity", "Open PnL", "Margin used"]

    let numberFormatterCurrency = NumberFormatter()
    let numberFormatterPercent = NumberFormatter()

    var canSwitch = false

    override func viewDidLoad() {
        super.viewDidLoad()

        numberFormatterCurrency.numberStyle = NumberFormatter.Style.currency
        numberFormatterCurrency.currencySymbol = ""

        numberFormatterPercent.numberStyle = NumberFormatter.Style.percent
        numberFormatterPercent.maximumFractionDigits = 1
        numberFormatterPercent.minimumFractionDigits = 1

        accountChanged()

        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(AccountViewController.accountChanged), name: NSNotification.Name(rawValue: accountDidChangeNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTexts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell

        cell.titleLabel?.text = cellTexts[indexPath.row]

        if indexPath.row == 3 {
            cell.valueLabel.font = UIFont(name: "HelveticaNeue", size: 24.0)
        }

        setCellValue(for: cell, at: indexPath)

        cell.backgroundColor = UIColor.clear

        return cell
    }

    @IBAction func nextAccountTap(_ sender: UIButton) {
        changeToNextAccount()
    }

    @IBAction func previousAccountTap(_ sender: UIButton) {
        changeToPrevAccount()
    }

    @IBAction func rightSwipe(_ sender: UISwipeGestureRecognizer) {
        changeToPrevAccount()
    }

    @IBAction func leftSwipe(_ sender: UISwipeGestureRecognizer) {
        changeToNextAccount()
    }

    func clearData() {
        accountSelector.accountLabel.text = nil
        accountSelector.brokerLogo.image = nil

        currency = nil
        metrics = nil
        updateData()
        canSwitch = false
    }

    func changeToPrevAccount() {
        if canSwitch && accountList.count > 1 {
            let idx = (accountIndex - 1) % accountList.count
            accountIndex = idx >= 0 ? idx : accountList.count + idx
            currentAccount = accountList[accountIndex]
        }
    }

    func changeToNextAccount() {
        if canSwitch && accountList.count > 1 {
            accountIndex = (accountIndex + 1) % accountList.count
            currentAccount = accountList[accountIndex]
        }
    }

    @objc func accountChanged() {
        clearData()

        if accountList.count > 1 {
            accountSelector.rightButton.isHidden = false
            accountSelector.leftButton.isHidden = false
        } else {
            accountSelector.rightButton.isHidden = true
            accountSelector.leftButton.isHidden = true
        }

        guard let currentAccount = currentAccount else { return }

        accountSelector.accountLabel.text = currentAccount.displayName
        currentAccount.brokerLogos.getOnLightBrokerLogo({ (logoImg) in
            self.accountSelector.brokerLogo.image = logoImg
        })

        currency = currentAccount.currencyIsoCode
        updateData()
        canSwitch = true
    }

    func updateData() {
        if let indexPaths = tableView?.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                let cell = tableView?.cellForRow(at: indexPath) as! AccountCell

                setCellValue(for: cell, at: indexPath)
            }
        }
    }

    func setCellValue(for cell: AccountCell, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.valueLabel.text = currency
        case 1:
            if let balance = metrics?.balance {
                cell.valueLabel.text = numberFormatterCurrency.string(from: NSNumber(value: balance))
            } else {
                cell.valueLabel.text = "..."
            }
        case 2:
            if let equity = metrics?.equity {
                cell.valueLabel.text = numberFormatterCurrency.string(from: NSNumber(value: equity))
            } else {
                cell.valueLabel.text = "..."
            }
        case 3:
            if let openPnL = metrics?.openProfit {
                cell.valueLabel.textColor = openPnL >= 0 ? greenColor : pinkColor
                cell.valueLabel.text = numberFormatterCurrency.string(from: NSNumber(value: openPnL))
            } else {
                cell.valueLabel.textColor = UIColor.black
                cell.valueLabel.text = "..."
            }
        case 4:
            if let marginAmountUsed = metrics?.marginAmountUsed, let equity = metrics?.equity {
                if equity != 0 {
                    cell.valueLabel.text = numberFormatterPercent.string(from: NSNumber(value: marginAmountUsed/equity))
                } else {
                    cell.valueLabel.text = "..."
                }
            } else {
                cell.valueLabel.text = "..."
            }
        default:
            break
        }
    }

    @IBAction func addAccountTap(_ sender: UIButton) {
        tradable.authenticate(withAppId: appId, uri: customUri, viewController: self, showLogin: true)
    }

    @IBAction func disconnectAccountTap(_ sender: UIButton) {
        currentAccount!.getAccessToken()?.dispose()
        removeAccount(currentAccount!)
    }
}

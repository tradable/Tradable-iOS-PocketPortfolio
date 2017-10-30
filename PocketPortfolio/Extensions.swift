//
//  Extensions.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

let EPSILON: Double = 0.00000001

let greenColor = UIColor(red: 38.0/255.0, green: 209.0/255.0, blue: 193.0/255.0, alpha: 1.0)
let darkGreenColor = UIColor(red: 0.0/255.0, green: 140.0/255.0, blue: 149.0/255.0, alpha: 1.0)
let pinkColor = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 191.0/255.0, alpha: 1.0)
let darkPinkColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 1.0)
let lineColor = UIColor(red: 16.0/255.0, green: 137.0/255.0, blue: 147.0/255.0, alpha: 0.1)
let whiteLineColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)

let customUri = "com.tradable.ios.pocketportfolio://oauth2callback"

let appId: UInt64 = 100100

let accountDidChangeNotificationKey = "com.tradable.ios.pocketportfolio.accountDidChange"

var tradable = Tradable.sharedInstance

var updatesRequest = TradableUpdatesRequest(instrumentIds: [])

var cachedInstruments: [String: TradableInstrument] = [:]

var accountIndex: Int = 0

var accountList: [TradableAccount] = [TradableAccount]()

func addAccount(_ account: TradableAccount) {
    var i = 0
    for _account in accountList {
        if _account.id == account.id {
            break
        }
        i += 1
    }
    if i == accountList.count {
        print("Account \(account.id) added.")
        accountList.append(account)

        accountIndex = accountList.count - 1

        currentAccount = accountList[accountIndex]
    }
}

func removeAccount(_ account: TradableAccount) {
    accountList = accountList.filter({
        $0.id != account.id
    })
    print("Account \(account.id) removed.")
    if accountList.count == 0 {
        currentAccount = nil
        showLoggedOutAlert()
    } else {
        accountIndex = accountList.count - 1
        currentAccount = accountList[accountIndex]
    }
}

private func showLoggedOutAlert() {
    let alert = UIAlertController(title: nil, message: "There are no active accounts. Please sign in again.", preferredStyle: .alert)

    let loginAction = UIAlertAction(title: "Sign in", style: .default) { _ in
       tradable.authenticate(withAppId: appId, uri: customUri, viewController: UIApplication.topViewController())
    }

    alert.addAction(loginAction)

    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
}

var currentAccount: TradableAccount? {
    willSet {
        currentAccount?.stopUpdates()
        instrumentIdsForUpdates = []
        cachedInstruments = [:]
        updatesRequest = TradableUpdatesRequest(instrumentIds: instrumentIdsForUpdates)
    }
    didSet {
        NotificationCenter.default.post(name: Notification.Name(rawValue: accountDidChangeNotificationKey), object: nil)
        if let ca = currentAccount {
            ca.startUpdates(ofType: .full, withFrequency: .oneSecond, with: updatesRequest)
        }
    }
}

var instrumentIdsForUpdates: [String] = [] {
    didSet {
        updatesRequest = TradableUpdatesRequest(instrumentIds: instrumentIdsForUpdates)
        currentAccount?.setUpdatesRequest(updatesRequest)
    }
}

//EXTENSIONS
extension UIImage {
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIButton {
    func fadeGreen() {
        self.layer.removeAllAnimations()
        self.backgroundColor = greenColor
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction.union(.curveEaseOut), animations: { () -> Void in
            self.backgroundColor = UIColor.clear
            }, completion: nil)
    }

    func fadePink() {
        self.layer.removeAllAnimations()
        self.backgroundColor = pinkColor
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction.union(.curveEaseOut), animations: { () -> Void in
            self.backgroundColor = UIColor.clear
        }, completion: nil)
    }
}

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

//global helper UI methods

func drawLine(color: UIColor) -> UIImage {
    let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    context?.setStrokeColor(color.cgColor)
    context?.setLineWidth(1.0)

    context?.beginPath()
    context?.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
    context?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
    context?.strokePath()

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

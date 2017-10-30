//
//  TabBarController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    let whitishColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)

    var tradeButton = UIButton()

    var isSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)

        self.tabBar.tintColor = greenColor
        self.tabBar.barTintColor = whitishColor

        self.tabBar.selectionIndicatorImage = UIImage.imageWithColor(UIColor.white, size: tabBarItemSize).resizableImage(withCapInsets: UIEdgeInsets.zero)

        self.tabBar.frame.size.width = self.view.frame.width + 4
        self.tabBar.frame.origin.x = -2

        self.tabBar.backgroundColor = whitishColor
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()

        self.delegate = self

        let middleImage: UIImage = UIImage(named: "trade")!
        let selectedStateMiddleImage: UIImage = UIImage(named: "tradeBack")!

        addCenterButtonWithImage(middleImage, selectedStateImage: selectedStateMiddleImage)

        tradable.eventsDelegate = self.viewControllers?[0] as? TradableEventsDelegate
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if !(viewController is TradeViewController) {
            deselectMiddleButton()
        }

        tradable.eventsDelegate = viewController as? TradableEventsDelegate
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == selectedViewController {
            return false
        } else {
            if self.selectedViewController?.presentedViewController != nil {
                self.selectedViewController?.dismiss(animated: true, completion: nil)
            }
            return true
        }
    }

    func addCenterButtonWithImage(_ buttonImage: UIImage, selectedStateImage: UIImage?) {
        tradeButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: buttonImage.size.width, height: buttonImage.size.height))
        tradeButton.setBackgroundImage(buttonImage, for: UIControlState())
        tradeButton.setBackgroundImage(buttonImage, for: UIControlState.highlighted)
        tradeButton.setBackgroundImage(selectedStateImage, for: UIControlState.selected)
        tradeButton.setBackgroundImage(selectedStateImage, for: UIControlState.selected.union(UIControlState.highlighted))

        let heightDifference: CGFloat = buttonImage.size.height - self.tabBar.frame.size.height
        if heightDifference < 0 {
            tradeButton.center = self.tabBar.center
        } else {
            var center: CGPoint = self.tabBar.center
            center.y -= heightDifference/2.0
            tradeButton.center = center
        }

        tradeButton.addTarget(self, action: #selector(TabBarController.changeTabToMiddleTab(_:)), for: UIControlEvents.touchUpInside)

        view.addSubview(tradeButton)
    }

    @objc func changeTabToMiddleTab(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
            if self.isSelected {
                self.selectedViewController?.dismiss(animated: true, completion: { () -> Void in
                    self.deselectMiddleButton()
                })
            } else {
                if self.selectedViewController?.presentedViewController != nil {
                    self.selectedViewController?.dismiss(animated: true, completion: { () -> Void in
                        self.selectedViewController!.tradablePresentOrderEntry(for: currentAccount!, with: nil, withSide: .buy, delegate: self.selectedViewController as? TradableOrderEntryDelegate, presentationStyle: UIModalPresentationStyle.overCurrentContext)
                    })
                } else {
                    self.selectedViewController!.tradablePresentOrderEntry(for: currentAccount!, with: nil, withSide: .buy, delegate: self.selectedViewController as? TradableOrderEntryDelegate, presentationStyle: UIModalPresentationStyle.overCurrentContext)
                }
                self.selectMiddleButton()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func deselectMiddleButton() {
        isSelected = false
        tradeButton.isHighlighted = false
        tradeButton.isSelected = false
    }

    func selectMiddleButton() {
        isSelected = true
        tradeButton.isSelected = true
    }
}

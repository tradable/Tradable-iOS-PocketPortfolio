//
//  TabBarController.swift
//  TradableExampleApp
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
        
        self.tabBar.selectionIndicatorImage = UIImage.imageWithColor(UIColor.whiteColor(), size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        self.tabBar.frame.size.width = self.view.frame.width + 4
        self.tabBar.frame.origin.x = -2
        
        self.tabBar.backgroundColor = whitishColor
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        
        self.delegate = self
        
        let middleImage:UIImage = UIImage(named:"trade")!
        let selectedStateMiddleImage:UIImage = UIImage(named:"tradeBack")!
        
        addCenterButtonWithImage(middleImage, selectedStateImage: selectedStateMiddleImage)
        
        tradable.delegate = self.viewControllers?[0] as? TradableAPIDelegate
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if !viewController.isKindOfClass(TradeViewController) {
            deselectMiddleButton()
        }
        
        tradable.delegate = viewController as? TradableAPIDelegate
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController == selectedViewController {
            return false
        } else {
            if self.selectedViewController?.presentedViewController != nil {
                self.selectedViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            return true
        }
    }
    
    func addCenterButtonWithImage(buttonImage: UIImage, selectedStateImage:UIImage?) {
        tradeButton = UIButton(frame: CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height))
        tradeButton.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        tradeButton.setBackgroundImage(buttonImage, forState: UIControlState.Highlighted)
        tradeButton.setBackgroundImage(selectedStateImage, forState: UIControlState.Selected)
        tradeButton.setBackgroundImage(selectedStateImage, forState: UIControlState.Selected.union(UIControlState.Highlighted))
        
        let heightDifference:CGFloat = buttonImage.size.height - self.tabBar.frame.size.height
        if heightDifference < 0 {
            tradeButton.center = self.tabBar.center;
        } else {
            var center:CGPoint = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            tradeButton.center = center;
        }
        
        tradeButton.addTarget(self, action: "changeTabToMiddleTab:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(tradeButton)
    }
    
    func changeTabToMiddleTab(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            if self.isSelected {
                self.selectedViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.deselectMiddleButton()
                })
            } else {
                if self.selectedViewController?.presentedViewController != nil {
                    self.selectedViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                        tradable.presentOrderEntry(currentAccount!, symbol: nil, side: TradableOrderSide.BUY, delegate: self.selectedViewController as? TradableOrderEntryDelegate,  presentingViewController: self.selectedViewController!, presentationStyle: UIModalPresentationStyle.OverCurrentContext)
                    })
                } else {
                    tradable.presentOrderEntry(currentAccount!, symbol: nil, side: TradableOrderSide.BUY, delegate: self.selectedViewController as? TradableOrderEntryDelegate,  presentingViewController: self.selectedViewController!, presentationStyle: UIModalPresentationStyle.OverCurrentContext)
                }
                self.selectMiddleButton()
            }
        });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func deselectMiddleButton() {
        isSelected = false
        tradeButton.highlighted = false
        tradeButton.selected = false
    }
    
    func selectMiddleButton() {
        isSelected = true
        tradeButton.selected = true
    }
}
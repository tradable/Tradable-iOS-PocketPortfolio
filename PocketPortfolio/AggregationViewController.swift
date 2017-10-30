//
//  ChartSettingsViewController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 10/03/2017.
//  Copyright © 2017 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI

class AggregationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var aggregationPickerView: UIPickerView!

    var aggregation: Int = TradableAggregation.minute.rawValue

    let aggregations: [String] = ["1 minute", "5 minutes", "15 minutes", "30 minutes", "1 hour", "1 day", "1 week", "1 month"]

    let aggregationValues: [String: Int] = ["1 minute": TradableAggregation.minute.rawValue, "5 minutes": TradableAggregation.fiveMinutes.rawValue, "15 minutes": TradableAggregation.fifteenMinutes.rawValue, "30 minutes": TradableAggregation.thirtyMinutes.rawValue, "1 hour": TradableAggregation.hour.rawValue, "1 day": TradableAggregation.day.rawValue, "1 week": TradableAggregation.week.rawValue, "1 month": TradableAggregation.month.rawValue]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.aggregationPickerView.delegate = self
        self.aggregationPickerView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let row = rowForAggregation(aggregation: aggregation)
        aggregationPickerView.selectRow(row, inComponent: 0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aggregations.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return aggregations[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        aggregation = aggregationValues[aggregations[row]]!
    }

    @IBAction func closeTap(_ sender: UIButton) {
        let presentingVC = presentingViewController?.childViewControllers[3].childViewControllers[0] as? HistoryViewController
        self.dismiss(animated: true) {
            presentingVC?.aggregation = self.aggregation
            presentingVC?.presentingAggregationVC = false
        }
    }

    private func rowForAggregation(aggregation: Int) -> Int {
        for aggr in aggregations where aggregationValues[aggr] == aggregation {
            return aggregations.index(of: aggr)!
        }

        return 0
    }
}

//
//  ChartMarker.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 31/08/2017.
//  Copyright © 2017 Tradable ApS. All rights reserved.
//

import Foundation
import Charts
import TradableAPI

class ChartMarker: MarkerView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        super.awakeFromNib()
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let candleEntry = entry as! CandleChartDataEntry
        let data = candleEntry.data as! TradableCandle
        label.text = "O: \(candleEntry.open) H: \(candleEntry.high) L: \(candleEntry.low) C: \(candleEntry.close)"
        label.sizeToFit()
        timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.timestamp/1000)))
        timeLabel.sizeToFit()
        layoutIfNeeded()
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }

}

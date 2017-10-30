//
//  HistoryViewController.swift
//  PocketPortfolio
//
//  Created by Tradable ApS on 06/10/15.
//  Copyright © 2015 Tradable ApS. All rights reserved.
//

import UIKit

import TradableAPI
import Charts

class HistoryViewController: UIViewController, TradableEventsDelegate, TradableInstrumentSelectorDelegate, ChartViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var chartView: CandleStickChartView!
    @IBOutlet weak var instrumentButton: UIBarButtonItem!
    @IBOutlet weak var aggregationButton: UIBarButtonItem!

    var instrument: TradableInstrument? {
        didSet {
            if instrument != oldValue {
                scrollToEnd = true
                chartView.noDataText = instrument == nil ? "Please select an instrument." : "Waiting for prices..."
                chartView.clear()
                currentAccount?.stopCandleUpdates()
                instrumentButton.title = "Instrument"

                if let instrument = instrument {
                    moreDataAvailable = true
                    let secondsAgo = 60 * entryCountToLoad * aggregation
                    currentAccount!.startCandleUpdates(for: instrument, aggregation: aggregation, from: UInt64((Date().timeIntervalSince1970 - Double(secondsAgo)) * 1000))
                    self.instrumentButton.title = instrument.brokerageAccountSymbol
                    chartView.rightAxis.valueFormatter = PriceFormatter(instrument: instrument)
                    chartView.xAxis.valueFormatter = TimestampFormatter(chartView: chartView, dateFormatter: dateFormatter)
                }
            }
        }
    }

    var aggregation: Int = TradableAggregation.minute.rawValue {
        didSet {
            switch aggregation {
            case TradableAggregation.month.rawValue:
                dateFormatter.dateFormat = "MMM yyyy"
                aggregationButton.title = "1 month"
            case TradableAggregation.week.rawValue:
                aggregationButton.title = "1 week"
            case TradableAggregation.day.rawValue:
                dateFormatter.dateFormat = "MMM d yyyy"
                aggregationButton.title = "1 day"
            case TradableAggregation.hour.rawValue:
                dateFormatter.dateFormat = "MMM d HH:mm"
                aggregationButton.title = "1 hour"
            case TradableAggregation.thirtyMinutes.rawValue:
                dateFormatter.dateFormat = "MMM d HH:mm"
                aggregationButton.title = "30 minutes"
            case TradableAggregation.fifteenMinutes.rawValue:
                dateFormatter.dateFormat = "HH:mm"
                aggregationButton.title = "15 minutes"
            case TradableAggregation.fiveMinutes.rawValue:
                dateFormatter.dateFormat = "HH:mm"
                aggregationButton.title = "5 minutes"
            case TradableAggregation.minute.rawValue:
                dateFormatter.dateFormat = "HH:mm"
                aggregationButton.title = "1 minute"
            default:
                dateFormatter.dateFormat = "HH:mm"
                aggregationButton.title = "1 minute"
            }
            if aggregation != oldValue {
                guard let instrument = instrument else { return }

                scrollToEnd = true
                chartView.noDataText = "Waiting for prices..."
                chartView.clear()
                currentAccount!.stopCandleUpdates()
                let secondsAgo = 60 * entryCountToLoad * aggregation
                currentAccount!.startCandleUpdates(for: instrument, aggregation: aggregation, from: UInt64((Date().timeIntervalSince1970 - Double(secondsAgo)) * 1000))
                chartView.rightAxis.valueFormatter = PriceFormatter(instrument: instrument)
                chartView.xAxis.valueFormatter = TimestampFormatter(chartView: chartView, dateFormatter: dateFormatter)
            }
        }
    }

    let valueFormatter = IndexAxisValueFormatter()

    let amountFormatter = NumberFormatter()
    let priceFormatter = NumberFormatter()

    var entryCountToLoad: Int = 120

    var pendingOrders: [TradableOrder] = []
    var openPositions: [TradablePosition] = []

    let dateFormatter = DateFormatter()

    var scrollToEnd = true

    var fetching = false
    var wasDragging = false
    var moreDataAvailable = true

    var presentingAggregationVC = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChart()

        amountFormatter.numberStyle = NumberFormatter.Style.none
        amountFormatter.minimumIntegerDigits = 1
        amountFormatter.minimumFractionDigits = 0
        amountFormatter.usesGroupingSeparator = true

        priceFormatter.numberStyle = NumberFormatter.Style.decimal
        priceFormatter.minimumFractionDigits = 2

        dateFormatter.dateFormat = "HH:mm"

        NotificationCenter.default.addObserver(self, selector: #selector(HistoryViewController.accountChanged), name: NSNotification.Name(rawValue: accountDidChangeNotificationKey), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !presentingAggregationVC {
            chartView.clear()
            currentAccount!.stopCandleUpdates()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !presentingAggregationVC {
            presentingAggregationVC = false

            if let instrument = instrument {
                let secondsAgo = 60 * entryCountToLoad * aggregation
                currentAccount!.startCandleUpdates(for: instrument, aggregation: aggregation, from: UInt64((Date().timeIntervalSince1970 - Double(secondsAgo)) * 1000))
            }

            scrollToEnd = true
        }
    }

    @objc func accountChanged() {
        instrument = nil
    }

    private func setupChart() {
        chartView.noDataText = "Please select an instrument."
        chartView.noDataFont = UIFont.systemFont(ofSize: 18.0)

        chartView.highlightPerDragEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.dragDecelerationEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = true

        chartView.chartDescription?.text = nil
        chartView.legend.enabled = false

        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = true
        //good to have it, but it's bugged in 3.0.1
        //chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.xAxis.axisLineWidth = 1.0
        chartView.xAxis.spaceMin = 3.0
        chartView.xAxis.spaceMax = 5.0
        chartView.xAxis.gridLineDashLengths = [25.0, 5.0]
        chartView.xAxis.gridLineDashPhase = 0.0
        chartView.xAxis.setLabelCount(4, force: false)

        chartView.rightAxis.drawGridLinesEnabled = true
        chartView.rightAxis.drawAxisLineEnabled = true
        chartView.rightAxis.axisLineWidth = 1.0
        chartView.rightAxis.gridLineDashLengths = [25.0, 5.0]
        chartView.rightAxis.gridLineDashPhase = 0.0
        chartView.rightAxis.setLabelCount(7, force: false)

        chartView.leftAxis.enabled = false

        chartView.minOffset = 0
        chartView.setExtraOffsets(left: 0, top: 5, right: 0, bottom: 25)

        let marker = ChartMarker.viewFromXib()!
        marker.chartView = chartView
        marker.sizeToFit()
        chartView.marker = marker

        chartView.delegate = self
    }

    @IBAction func presentInstrumentSelector(_ sender: UIBarButtonItem) {
        self.tradablePresentInstrumentSelector(for: currentAccount!, delegate: self, presentationStyle: .overFullScreen)
    }

    func tradableInstrumentSelectorDismissed(instrumentSearchResult: TradableInstrumentSearchResult?) {
        guard let instrumentSearchResult = instrumentSearchResult else { return }

        currentAccount!.getInstruments(with: TradableInstrumentSearchRequest(instrumentIds: [instrumentSearchResult.instrumentId])) { (instrumentList, _) in
            guard let instrument = instrumentList?.instruments.first else { return }

            self.instrument = instrument
        }
    }

    func candlesUpdated(candles: TradableCandleResponse) {
        addEntries(candles: candles.candles)
    }

    func ordersUpdated(orders: TradableOrders) {
        pendingOrders = orders.pending
    }

    func positionsUpdated(positions: TradablePositions) {
        openPositions = positions.open
    }

    func eventsError(error: TradableError) {
        if error.errorCode == 20 {
            chartView.noDataText = "No data available."
            chartView.setNeedsDisplay()
        }
    }

    private func addEntries(candles: [TradableCandle]) {
        if !candles.isEmpty {
            var needToMove = false

            if chartView.data == nil {
                let set = createSet()
                var i = 0
                for candle in candles {
                    _ = set.addEntry(CandleChartDataEntry(x: Double(i), shadowH: candle.high, shadowL: candle.low, open: candle.open, close: candle.close, data: candle))
                    i += 1
                }
                needToMove = true

                chartView.data = CandleChartData(dataSet: set)
            } else {
                let data = chartView.candleData!
                let entryCount = data.getDataSetByIndex(0).entryCount
                let candle = candles[0]
                let lastEntry = data.getDataSetByIndex(0).entryForIndex(entryCount - 1) as! CandleChartDataEntry
                if (lastEntry.data as? TradableCandle)?.timestamp == candle.timestamp {
                    updateEntry(lastEntry, candle: candle)
                    if candles.count > 1 { //we might get an updated candle AND a new candle
                        let newCandle = candles[1]
                        data.addEntry(CandleChartDataEntry(x: Double(entryCount), shadowH: newCandle.high, shadowL: newCandle.low, open: newCandle.open, close: newCandle.close, data: newCandle), dataSetIndex: 0)
                    }
                } else {
                    data.addEntry(CandleChartDataEntry(x: Double(entryCount), shadowH: candle.high, shadowL: candle.low, open: candle.open, close: candle.close, data: candle), dataSetIndex: 0)
                }
            }

            chartView.getAxis(.right).removeAllLimitLines()

            for order in pendingOrders where order.instrumentId == instrument!.id {
                do {
                    amountFormatter.maximumFractionDigits = try instrument!.getOrderSizeDecimals(forOrderSize: order.amount)
                } catch _ {
                    amountFormatter.maximumFractionDigits = 1
                }
                do {
                    priceFormatter.minimumFractionDigits = try instrument!.getPriceDecimals(forPrice: order.price)
                } catch _ {
                    if let pipPrecision = instrument!.pipPrecision {
                        priceFormatter.minimumFractionDigits = pipPrecision + 1
                    }
                }
                let limitLine = ChartLimitLine(limit: order.price, label: (order.side == .buy ? "BUY " : "SELL ") + amountFormatter.string(from: NSNumber(value: order.amount))! + " @ " + priceFormatter.string(from: NSNumber(value: order.price))!)
                limitLine.lineWidth = 0.75
                limitLine.lineColor = order.side == .buy ? greenColor : pinkColor
                chartView.getAxis(.right).addLimitLine(limitLine)
            }

            for position in openPositions where position.instrumentId == instrument!.id {
                do {
                    amountFormatter.maximumFractionDigits = try instrument!.getOrderSizeDecimals(forOrderSize: position.amount)
                } catch _ {
                    amountFormatter.maximumFractionDigits = 1
                }
                do {
                    priceFormatter.minimumFractionDigits = try instrument!.getPriceDecimals(forPrice: position.openPrice)
                } catch _ {
                    if let pipPrecision = instrument!.pipPrecision {
                        priceFormatter.minimumFractionDigits = pipPrecision + 1
                    }
                }
                let limitLine = ChartLimitLine(limit: position.openPrice, label: (position.side == .buy ? "LONG " : "SHORT ") + amountFormatter.string(from: NSNumber(value: position.amount))! + " @ " + priceFormatter.string(from: NSNumber(value: position.openPrice))!)
                limitLine.lineWidth = 1
                limitLine.lineColor = position.side == .buy ? greenColor : pinkColor
                chartView.getAxis(.right).addLimitLine(limitLine)
            }

            chartView.notifyDataSetChanged()

            chartView.autoScaleMinMaxEnabled = true
            chartView.setVisibleXRange(minXRange: Double(10), maxXRange: Double(60))

            if needToMove {
                chartView.moveViewToX(Double(chartView.candleData!.getDataSetByIndex(0).entryCount - 1))
            } else {
                chartView.setNeedsDisplay()
            }

        } else {
            chartView.noDataText = "No data available."
            chartView.setNeedsDisplay()
        }
    }

    private func updateEntry(_ entry: CandleChartDataEntry, candle: TradableCandle) {
        entry.open = candle.open
        entry.high = candle.high
        entry.low = candle.low
        entry.close = candle.close
        entry.data = candle
    }

    private func createSet() -> CandleChartDataSet {
        let candleChartDataSet = CandleChartDataSet(values: nil, label: nil)
        candleChartDataSet.axisDependency = .right
        candleChartDataSet.drawIconsEnabled = false
        candleChartDataSet.drawValuesEnabled = false
        candleChartDataSet.shadowWidth = 1.0
        candleChartDataSet.decreasingColor = darkPinkColor
        candleChartDataSet.decreasingFilled = true
        candleChartDataSet.increasingColor = darkGreenColor
        candleChartDataSet.increasingFilled = true
        candleChartDataSet.neutralColor = NSUIColor.gray
        candleChartDataSet.shadowColorSameAsCandle = true
        candleChartDataSet.highlightColor = NSUIColor.black
        candleChartDataSet.highlightLineWidth = 0.5

        return candleChartDataSet
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentAggregationVC" {
            guard let chartSettingsVC = segue.destination as? AggregationViewController else { return }
            presentingAggregationVC = true
            chartSettingsVC.aggregation = self.aggregation
        }
    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        wasDragging = true
    }

    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            wasDragging = false
        }

        if sender.state == .ended {
            guard let data = chartView.data, let entry = data.getDataSetByIndex(0).entryForIndex(10) else { return }

            if wasDragging && moreDataAvailable {
                let lowestVisX = chartView.lowestVisibleX
                if lowestVisX <= entry.x && !fetching {
                    fetching = true

                    let firstTimestamp = ((data.getDataSetByIndex(0).entryForIndex(0) as! CandleChartDataEntry).data as! TradableCandle).timestamp

                    currentAccount!.getCandles(with: TradableCandleRequest(instrumentId: instrument!.id, from: firstTimestamp - UInt64((Double(60 * entryCountToLoad * aggregation)) * 1000), to: firstTimestamp - UInt64(aggregation * 60 * 1000), aggregation: aggregation)) { (candles, _) in
                        guard let candles = candles else {
                            self.moreDataAvailable = false
                            self.fetching = false
                            return
                        }

                        if !candles.candles.isEmpty {
                            let highlighted = self.chartView.highlighted

                            let dataSet = self.chartView.data!.getDataSetByIndex(0)!

                            let candleChartDataSet = self.createSet()

                            for i in 0..<candles.candles.count {
                                let candle = candles.candles[i]
                                _ = candleChartDataSet.addEntry(CandleChartDataEntry(x: Double(i), shadowH: candle.high, shadowL: candle.low, open: candle.open, close: candle.close, data: candle))
                            }

                            for index in 0..<dataSet.entryCount {
                                let candleEntry = dataSet.entryForIndex(index) as! CandleChartDataEntry
                                _ = candleChartDataSet.addEntry(CandleChartDataEntry(x: Double(candles.candles.count + index), shadowH: candleEntry.high, shadowL: candleEntry.low, open: candleEntry.open, close: candleEntry.close, data: candleEntry.data))
                            }

                            self.chartView.data!.removeDataSetByIndex(0)
                            self.chartView.data!.addDataSet(candleChartDataSet)

                            self.chartView.notifyDataSetChanged()

                            self.chartView.autoScaleMinMaxEnabled = true
                            self.chartView.setVisibleXRange(minXRange: Double(10), maxXRange: Double(60))

                            self.chartView.moveViewToX(lowestVisX + Double(candles.candles.count))

                            //move highlighted values
                            if !highlighted.isEmpty {
                                var highlights = [Highlight]()
                                for highlight in highlighted {
                                    highlights.append(Highlight(x: highlight.x + Double(candles.candles.count), y: highlight.y, dataSetIndex: 0))
                                }
                                self.chartView.highlightValues(highlights)

                            }

                            self.fetching = false
                        } else {
                            self.moreDataAvailable = false
                            self.fetching = false
                        }
                    }
                }
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    class PriceFormatter: NSObject, IAxisValueFormatter {
        let instrument: TradableInstrument
        let priceFormatter = NumberFormatter()
        init(instrument: TradableInstrument) {
            self.instrument = instrument
            priceFormatter.numberStyle = .decimal
            super.init()
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            priceFormatter.minimumFractionDigits = instrument.pipPrecision == nil ? try! instrument.getPriceDecimals(forPrice: value) : instrument.pipPrecision! + 1
            return priceFormatter.string(from: NSNumber(value: value))!
        }
    }

    class TimestampFormatter: NSObject, IAxisValueFormatter {
        weak var chartView: CandleStickChartView!
        let dateFormatter: DateFormatter

        init(chartView: CandleStickChartView, dateFormatter: DateFormatter) {
            self.chartView = chartView
            self.dateFormatter = dateFormatter
            super.init()
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if let data = chartView.data, let dataSet = data.getDataSetByIndex(0), Double(dataSet.entryCount) > value, value >= 0 {
                let timestamp = (dataSet.entryForIndex(Int(value))!.data as! TradableCandle).timestamp
                return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp/1000)))
            } else {
                return ""
            }
        }
    }
}

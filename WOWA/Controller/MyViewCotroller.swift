//
//  MyViewCotroller.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/11.
//

import UIKit
import RealmSwift
import Highcharts

class MyViewCotroller: UIViewController {
    var weekData: [Weight]?
    var monthData: [Weight]?
    var yearData: [Weight]?
    let dateFormatter = DateFormatter()
    var today: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(makeChart("week"))
    }
    
    
    @IBAction func chartSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("week")
            self.view.addSubview(makeChart("week"))
        case 1:
            print("month")
            self.view.addSubview(makeChart("month"))
        case 2:
            print("year")
            self.view.addSubview(makeChart("year"))
        default: return
        }
    }
    
    func makeChart(_ duration: String) -> UIView {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        today = dateFormatter.string(from: Date())
        // 차트 설정
        let chartView = HIChartView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.width))
        chartView.theme = "dark-unica"
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "column"
        chart.marginLeft = 10
        chart.marginRight = 10
        chart.options3d = HIOptions3d()
        chart.options3d.enabled = true
        chart.options3d.alpha = 30
        chart.options3d.beta = 10
        chart.options3d.depth = 50
        chart.options3d.viewDistance = 0
        options.chart = chart
        
        let exporting = HIExporting()
        exporting.enabled = true
        options.exporting = exporting
        let title = HITitle()
        title.text = "Chart rotation demo"
        options.title = title
        
        let subtitle = HISubtitle()
        subtitle.text = "Test options by dragging the sliders below"
        options.subtitle = subtitle
        
        let plotOptions = HIPlotOptions()
        plotOptions.column = HIColumn()
        plotOptions.column.depth = 25
        options.plotOptions = plotOptions
        
        let column = HIColumn()
        if duration == "week" {
            column.data = DatabaseManager.manager.loadWeightDataForWeek()
        } else if duration == "month" {
            column.data = DatabaseManager.manager.loadWeightDataForMonth()
        } else {
            column.data = DatabaseManager.manager.loadWeightDataForYear()
        }
        options.series = [column]
        
        let credits = HICredits()
        let position = HIAlignObject()
        position.align = "center"
        credits.position = position
        options.credits = credits
        
        chartView.options = options
        
        
        return chartView
    }
    
}

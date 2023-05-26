//
//  MyViewCotroller.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/11.
//

import UIKit
import RealmSwift
import Highcharts
import KakaoSDKTemplate
import KakaoSDKCommon
import KakaoSDKShare


class MyViewCotroller: UIViewController {
    var weekData: [Weight]?
    var monthData: [Weight]?
    var yearData: [Weight]?
    let dateFormatter = DateFormatter()
    var today: String?
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addSubview(makeChart("week"))
        //self.view.addSubview(makeSpiderChart())
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
    func makeSpiderChart() -> UIView {
        let y = segment.frame.origin.y + (segment.frame.origin.y - view.bounds.width) + segment.frame.height
        let chartView = HIChartView(frame: CGRect(x: 0.0, y: y, width: view.bounds.width, height: view.bounds.width / 2))
        chartView.theme = "dark-unica"
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.polar = true
        chart.type = "line"
        options.chart = chart
        
        let title = HITitle()
        title.text = "부위별 통계"
        title.x = -80
        options.title = title
        
        let pane = HIPane()
        pane.size = "90%"
        options.pane = pane
        
        let xAxis = HIXAxis()
        xAxis.categories = wowa.bodyPart
        xAxis.tickmarkPlacement = "on"
        xAxis.lineWidth = 0
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.gridLineInterpolation = "polygon"
        yAxis.lineWidth = 0
        yAxis.min = 0
        options.yAxis = [yAxis]
        
        let tooltip = HITooltip()
        tooltip.shared = true
        tooltip.pointFormat = "<span style=\"color:{series.color}\">{series.name}: <b>{point.y:,.0f}kg</b><br/>"
        options.tooltip = tooltip
        
        let legend = HILegend()
        legend.align = "right"
        legend.verticalAlign = "middle"
        legend.layout = "vertical"
        options.legend = legend
        
        let budget = HILine()
        budget.name = "부위 별 중량 총합"
        budget.data = DatabaseManager.manager.loadWeightDataForSpiderChart()
        budget.pointPlacement = "on"
        options.series = [budget]
        
        let responsive = HIResponsive()
        
        let rule = HIRules()
        rule.condition = HICondition()
        rule.condition.maxWidth = 500
        
        rule.chartOptions = [
            "legend": [
                "align": "center",
                "verticalAlign": "bottom",
                "layout": "horizontal"
            ],
            "pane": [
                "size": "70%"
            ]
        ]
        
        responsive.rules = [rule]
        
        chartView.options = options
        
        return chartView
    }
    
    
    
}


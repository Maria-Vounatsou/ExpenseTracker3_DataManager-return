//
//  BarChartWrapper.swift
//  ExperimentApp
//
//  Created by Vounatsou, Maria on 6/9/24.
//
//
import SwiftUI
import DGCharts

struct PieChartWrapper: UIViewRepresentable {
    
    
    @ObservedObject var viewModel: PieChartViewModel
    
    func makeUIView(context: Context) -> PieChartView {
        PieChartView()
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        let dataSet = PieChartDataSet(entries: viewModel.pieChartDataEntries)
        dataSet.colors = ChartColorTemplates.pastel() // Use a predefined color template
        
        // Disable drawing entry labels (category names)
        uiView.drawEntryLabelsEnabled = false
        
        // Use the custom percent value formatter
        //let customFormatter = CustomPercentValueFormatter()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = "%"
        
        let data = PieChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueTextColor(.white)
        data.setValueFont(.boldSystemFont(ofSize: 16))
        
        uiView.data = data
        uiView.usePercentValuesEnabled = true
        uiView.centerText = "Overall"
        uiView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
        
        // Customize the legend
        let legend = uiView.legend
        legend.textColor = .white
        legend.font = UIFont.systemFont(ofSize: 12)
        
    }
    
    typealias UIViewType = PieChartView
}

// Custom Percent Value Formatter
//class CustomPercentValueFormatter: ValueFormatter {
//    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
//        return String(format: "%.1f%%", value)  // Display the percentage value with the symbol
//    }
//}


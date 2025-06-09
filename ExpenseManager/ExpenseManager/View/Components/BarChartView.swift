//
//  BarChartView.swift
//  ExpenseManager
//
//  Created by User on 08.06.2025.
//

import SwiftUI
import Charts

struct BarChartView: View {
    
    @ObservedObject var viewModel: MainScreenViewModel = .shared
    
    var body: some View {
        
        Chart(viewModel.cachedDailyExpenses) { expense in
            BarMark(
                x: .value("Дата", expense.date, unit: .day),
                y: .value("Сумма", abs(expense.totalAmount))
            )
        }
        .frame(height: 250)
        .padding(.horizontal)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 4)) { value in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks() { value in
                AxisGridLine()
                AxisValueLabel() {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(Int(abs(doubleValue)))")
                    }
                }
            }
        }
    }
}

#Preview {
    BarChartView()
}

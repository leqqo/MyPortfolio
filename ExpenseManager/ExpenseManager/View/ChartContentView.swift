//
//  ChartContentView.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import SwiftUI
import Charts

struct ChartContentView: View {
    
    @ObservedObject var calendarViewModel = CalendarViewModel.shared
    @ObservedObject var mainScreenViewModel = MainScreenViewModel.shared
    @ObservedObject var chartViewModel = ChartContentViewModel.shared
    
    @State private var selectedChart: ChartType = .byDay
    
    var displayedDateRange: String {
        if let start = calendarViewModel.selectedStartDate, let end = calendarViewModel.selectedEndDate {
            return "\(start.formattedMonthCapitalized()) - \(end.formattedMonthCapitalized()) \(calendarViewModel.currentYearInt)"
        } else if let start = calendarViewModel.selectedStartDate {
            return "\(start.formattedMonthCapitalized()) \(calendarViewModel.currentYearInt)"
        } else {
            return calendarViewModel.currentDate.formattedMonthCapitalized()
        }
    }
    
    var byCategoryTotalAmount: Int {
        mainScreenViewModel.cachedExpensesByCategory.reduce(0) { $0 + abs(Int($1.amount)) }
    }
    
    var byDayTotalAmount: Int {
        mainScreenViewModel.cachedDailyExpenses.reduce(0) {$0 + abs(Int($1.totalAmount))}
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if mainScreenViewModel.transactions.isEmpty {
                emptyTransactions
            } else {
                ChartTypePickerView(selectedChart: $selectedChart)
                displayedTextRange(for: selectedChart)
                totalExpenses(for: selectedChart)
                chartContent(for: selectedChart)
            }
        }
        .frame(height: 350, alignment: .top)
        .padding(.horizontal)
        .onAppear {
            calendarViewModel.setCurrentMonthRange()
        }
    }
    
    @ViewBuilder
    func displayedTextRange(for selectedChart: ChartType) -> some View {
        let textView = Text(displayedDateRange)
            .fontWeight(.semibold)
            .foregroundStyle(.blue)
        
        if selectedChart == .byDay {
            textView
                .sheet(isPresented: $calendarViewModel.isCalendarShow) {
                    CalendarView()
                }
        } else {
            textView
                .onTapGesture {
                    calendarViewModel.isCalendarShow.toggle()
                }
                .sheet(isPresented: $calendarViewModel.isCalendarShow) {
                    CalendarView()
                }
        }
    }
    
    @ViewBuilder
    var chart: some View {
        Chart(mainScreenViewModel.cachedExpensesByCategory) { expense in
            SectorMark(
                angle: .value("Сумма", expense.amount),
                innerRadius: .ratio(0.5)
            )
            .foregroundStyle(chartViewModel.getColor(for: expense.category.title))
        }
        .chartLegend(.hidden)
    }
    
    @ViewBuilder
    var legend: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), alignment: .leading, spacing: 10) {
            ForEach(mainScreenViewModel.cachedExpensesByCategory) { expense in
                HStack {
                    Circle()
                        .fill(chartViewModel.getColor(for: expense.category.title))
                        .frame(width: 12, height: 12)
                    
                    Text(expense.category.title)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    func totalExpenses(for selectedChart: ChartType) -> some View {
        switch selectedChart {
        case .byDay:
            Text("Сумма расходов - \(byDayTotalAmount.formatAmount())")
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
                .opacity(mainScreenViewModel.cachedDailyExpenses.isEmpty ? 0 : 1)
            
        case .byCategory:
            Text("Сумма расходов - \(byCategoryTotalAmount.formatAmount())")
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
                .opacity(mainScreenViewModel.cachedExpensesByCategory.isEmpty ? 0 : 1)
        }
    }
    
    @ViewBuilder
    var noTransactions: some View {
        Spacer()
        Text("Транзакции за выбранный период отсутствуют")
            .foregroundStyle(Color(uiColor: .systemGray2))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
        Spacer()
    }
    
    @ViewBuilder
    var emptyTransactions: some View {
        VStack(spacing: 8) {
            Text("Транзакции отсутствуют!")
            Text("Чтобы добавить транзакцию, нажмите")
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .foregroundStyle(.blue)
                    .font(.title)
                Text("в правом верхнем углу")
            }
        }
        .padding(.top, 150)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    func chartContent(for selectedChart: ChartType) -> some View {
        switch selectedChart {
        case .byDay:
            if mainScreenViewModel.cachedDailyExpenses.isEmpty {
                noTransactions
            } else {
                BarChartView()
                    .padding(.top)
            }
            
        case .byCategory:
            if mainScreenViewModel.cachedExpensesByCategory.isEmpty {
                noTransactions
            } else {
                VStack {
                    chart
                    legend
                }
                .padding(.top)
            }
        }
    }
}

struct BarChartView: View {
    
    @ObservedObject private var viewModel: MainScreenViewModel = .shared
    
    var body: some View {
        Chart(viewModel.cachedDailyExpenses) { expense in
            BarMark(
                x: .value("Дата", expense.date, unit: .day),
                y: .value("Сумма", abs(expense.totalAmount))
            )
        }
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

struct ChartTypePickerView: View {
    
    @ObservedObject private var viewModel: MainScreenViewModel = .shared
    @Binding var selectedChart: ChartType
    
    var body: some View {
        Picker("Test", selection: $selectedChart) {
            Text("По дням").tag(ChartType.byDay)
            Text("По категориям").tag(ChartType.byCategory)
        }
        .pickerStyle(.segmented)
        .padding(.vertical)
    }
}

#Preview {
    MainScreenView()
}

#Preview {
    ChartContentView()
}



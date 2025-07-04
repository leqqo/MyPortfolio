//
//  MainScreenViewModel.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import SwiftUI
import Foundation

class MainScreenViewModel: ObservableObject {
    
    static let shared = MainScreenViewModel()

    private init() { loadTransactions() }
    
    @Published var transactions = [Transaction]() {
        didSet {
            saveTransactions()
            updateGroupedTransactions()
            updateExpensesByCategory()
            calculateDailyExpenses()
        }
    }
    @Published var cachedExpensesByCategory: [CategoryExpense] = []
    @Published var cachedDailyExpenses: [DailyExpense] = []
    var groupedTransactions: [(key: String, value: [Transaction])] = []
    
    private func updateGroupedTransactions() {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let sortedGrouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        .sorted { $0.key > $1.key }

        groupedTransactions = sortedGrouped.map { (date, transactions) in
            let label: String
            if calendar.isDate(date, inSameDayAs: today) {
                label = Locale.current.language.languageCode?.identifier == "ru" ? "Сегодня" : "Today"
            } else if calendar.isDate(date, inSameDayAs: yesterday) {
                label = Locale.current.language.languageCode?.identifier == "ru" ? "Вчера" : "Yesterday"
            } else {
                label = date.formattedMonthCapitalizedPlusYear()
            }
            return (key: label, value: transactions)
        }
    }

    private func calculateDailyExpenses() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let range = calendar.range(of: .day, in: .month, for: today),
              let endOfMonth = calendar.date(bySetting: .day, value: range.count, of: startOfMonth) else {
            return
        }
        
        let allDates = stride(
            from: startOfMonth,
            through: endOfMonth,
            by: 60 * 60 * 24
        ).map { calendar.startOfDay(for: $0) }
        
        let grouped: [Date: Double] = Dictionary(grouping: transactions) {
            calendar.startOfDay(for: $0.date)
        }.mapValues {
            $0.reduce(0) { $0 + Double($1.amount) }
        }
        
        cachedDailyExpenses = allDates.map {
            DailyExpense(date: $0, totalAmount: grouped[$0] ?? 0)
        }
    }
    
    func updateExpensesByCategory(singleDate: Date? = CalendarViewModel.shared.selectedStartDate, startDate: Date? = CalendarViewModel.shared.selectedStartDate, endDate: Date? = CalendarViewModel.shared.selectedEndDate) -> Void {
        
        var filteredTransactions: [Transaction] = []
        
        let calendar = Calendar.current
        let today = Date()
        
        let defaultStartDate = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let defaultEndDate = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: defaultStartDate)!
        
        if let startDate = startDate, let endDate = endDate {
            filteredTransactions = transactions.filter { $0.date >= startDate && $0.date <= endDate }
        } else if let singleDate = singleDate {
            filteredTransactions = transactions.filter { calendar.isDate($0.date, inSameDayAs: singleDate) }
        } else {
            filteredTransactions = transactions.filter { $0.date >= defaultStartDate && $0.date <= defaultEndDate }
        }
        
        let grouped = Dictionary(grouping: filteredTransactions, by: { $0.category.title })
        
        cachedExpensesByCategory = grouped.map { (_, transactions) in
            let totalAmount = transactions.reduce(0) { $0 + Double($1.amount) }
            let category = transactions.first!.category
            return CategoryExpense(category: category, amount: totalAmount)
        }
        .sorted { $0.amount < $1.amount }
    }
    
    private func loadTransactions() {

        if let data = UserDefaults.standard.data(forKey: "transactions"),
           let saved = try? JSONDecoder().decode([Transaction].self, from: data) {
            self.transactions = saved
        } else {
            let mockData = generateMockTransactions()
            self.transactions = mockData
        }
    }

    private func saveTransactions() {
        do {
            let data = try JSONEncoder().encode(transactions)
            UserDefaults.standard.set(data, forKey: "transactions")
        } catch {
            print("Не удалось сохранить транзакции: \(error)")
        }
    }
    
    private func generateMockTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        guard let startOfYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) else {
            return []
        }
        
        guard let dayCount = calendar.dateComponents([.day], from: startOfYear, to: now).day else {
            return []
        }
        
        var transactions: [Transaction] = []
        
        for day in 0...dayCount {
            let transactionCount = Int.random(in: 2...5)
            for _ in 0..<transactionCount {
                if let date = calendar.date(byAdding: .day, value: day, to: startOfYear) {
                    let amount = -Int.random(in: 50...2000)
                    let category = Category.allCategories.randomElement()!
                    transactions.append(Transaction(date: date, amount: amount, category: category))
                }
            }
        }
        
        return transactions
    }

}

#Preview {
    MainScreenView()
}

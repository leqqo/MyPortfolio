//
//  DailyExpense.swift
//  ExpenseManager
//
//  Created by User on 08.06.2025.
//

import Foundation

struct DailyExpense: Identifiable {
    
    let id = UUID()
    let date: Date
    let totalAmount: Double
}

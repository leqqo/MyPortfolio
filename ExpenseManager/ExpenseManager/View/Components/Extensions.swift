//
//  Extensions.swift
//  ExpenseManager
//
//  Created by User on 08.04.2025.
//

import Foundation
import SwiftUI

extension Date {
    func formattedMonthCapitalized() -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"

        let day = dayFormatter.string(from: self)
        let month = monthFormatter.string(from: self).prefix(1).uppercased() + monthFormatter.string(from: self).dropFirst()
        return "\(day) \(month)"
    }
    
    func formattedMonthCapitalizedPlusYear() -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "YYYY"

        let day = dayFormatter.string(from: self)
        let month = monthFormatter.string(from: self).prefix(1).uppercased() + monthFormatter.string(from: self).dropFirst()
        let year = yearFormatter.string(from: self)
        return "\(day) \(month) \(year)"
    }
}

extension Int {
    func formatAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " " // Разделитель тысяч — пробел
        formatter.maximumFractionDigits = 0 // Без копеек
        
        let formattedAmount = formatter.string(from: NSNumber(value: self)) ?? "\(0)"
        return "\(formattedAmount) ₴"
    }
}

extension View {
    func applyDefaultNavigationBarStyle() -> some View {
        self
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
    }
}

extension Category {
    
    // Основные расходы
    static let groceries = Category(title: "Продукты", icon: "cart.fill")
    static let cafes = Category(title: "Кафе и рестораны", icon: "cup.and.saucer.fill")
    static let clothing = Category(title: "Одежда и обувь", icon: "tshirt.fill")
    static let transport = Category(title: "Транспорт", icon: "car.fill")
    static let housing = Category(title: "Жильё и коммуналка", icon: "house.fill")
    
    // Быт
    static let household = Category(title: "Бытовые товары", icon: "wrench.and.screwdriver.fill")
    static let pets = Category(title: "Домашние животные", icon: "pawprint.fill")
    static let gifts = Category(title: "Подарки", icon: "gift.fill")
    static let internet = Category(title: "Связь и интернет", icon: "wifi")
    
    // Здоровье и красота
    static let health = Category(title: "Здоровье", icon: "cross.case.fill")
    static let pharmacy = Category(title: "Аптека", icon: "pills.fill")
    static let fitness = Category(title: "Спорт и фитнес", icon: "figure.run.circle.fill")
    static let personalCare = Category(title: "Уход за собой", icon: "scissors")
    
    // Образование и работа
    static let education = Category(title: "Образование", icon: "book.fill")
    static let work = Category(title: "Работа и бизнес", icon: "briefcase.fill")
    
    // Развлечения и досуг
    static let entertainment = Category(title: "Развлечения", icon: "gamecontroller.fill")
    static let travel = Category(title: "Путешествия", icon: "airplane")
    static let hobby = Category(title: "Хобби", icon: "paintpalette.fill")
    
    // Дети
    static let children = Category(title: "Дети", icon: "figure.2.and.child.holdinghands")
    
    // Финансовые обязательства
    static let loans = Category(title: "Кредиты и долги", icon: "creditcard.fill")
    static let taxes = Category(title: "Налоги и сборы", icon: "doc.plaintext.fill")
    
    // Прочее
    static let other = Category(title: "Прочее", icon: "questionmark.circle.fill")
    
    static let allCategories: [Category] = [
        groceries, cafes, clothing, transport, housing, household, pets, gifts, internet,
        health, pharmacy, fitness, personalCare, education, work, entertainment, travel,
        hobby, children, loans, taxes, other
    ]
}

//
//  Extensions.swift
//  ExpenseManager
//
//  Created by User on 08.04.2025.
//

import Foundation
import SwiftUI

extension Color {
    func toHex() -> String {
            let uiColor = UIColor(self)
            guard let components = uiColor.cgColor.components, components.count >= 3 else {
                return "#FFFFFF"
            }

            let r = Int(components[0] * 255)
            let g = Int(components[1] * 255)
            let b = Int(components[2] * 255)

            return String(format: "#%02X%02X%02X", r, g, b)
        }
    
    static func fromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized = String(hexSanitized.dropFirst())
        }
        
        if hexSanitized.count == 6, let rgb = Int(hexSanitized, radix: 16) {
            return Color(
                red: Double((rgb >> 16) & 0xFF) / 255.0,
                green: Double((rgb >> 8) & 0xFF) / 255.0,
                blue: Double(rgb & 0xFF) / 255.0
            )
        }
        
        return .white
    }
}

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
    static let groceries = Category(title: "Продукты", icon: "basket.fill", iconColor: Color.red.toHex())
    static let cafes = Category(title: "Кафе и рестораны", icon: "cup.and.saucer.fill", iconColor: Color.orange.toHex())
    static let clothing = Category(title: "Одежда и обувь", icon: "tshirt.fill", iconColor: Color.brown.toHex())
    static let transport = Category(title: "Транспорт", icon: "car.fill", iconColor: Color.pink.toHex())
    static let housing = Category(title: "Жильё и коммуналка", icon: "house.fill", iconColor: Color.green.toHex())
    
    // Быт
    static let household = Category(title: "Бытовые товары", icon: "wrench.and.screwdriver.fill", iconColor: Color.purple.toHex())
    static let pets = Category(title: "Домашние животные", icon: "pawprint.fill", iconColor: Color.teal.toHex())
    static let gifts = Category(title: "Подарки", icon: "gift.fill", iconColor: Color.orange.toHex())
    static let internet = Category(title: "Связь и интернет", icon: "wifi", iconColor: Color.blue.toHex())
    
    // Здоровье и красота
    static let health = Category(title: "Здоровье", icon: "cross.case.fill", iconColor: Color.teal.toHex())
    static let pharmacy = Category(title: "Аптека", icon: "pills.fill", iconColor: Color.mint.toHex())
    static let fitness = Category(title: "Спорт и фитнес", icon: "figure.run.circle.fill", iconColor: Color.brown.toHex())
    static let personalCare = Category(title: "Уход за собой", icon: "scissors", iconColor: Color.cyan.toHex())
    
    // Образование и работа
    static let education = Category(title: "Образование", icon: "book.fill", iconColor: Color.blue.toHex())
    static let work = Category(title: "Работа и бизнес", icon: "briefcase.fill", iconColor: Color.indigo.toHex())
    
    // Развлечения и досуг
    static let entertainment = Category(title: "Развлечения", icon: "gamecontroller.fill", iconColor: Color.red.toHex())
    static let travel = Category(title: "Путешествия", icon: "airplane", iconColor: Color.blue.toHex())
    static let hobby = Category(title: "Хобби", icon: "paintpalette.fill", iconColor: Color.orange.toHex())
    
    // Дети
    static let children = Category(title: "Дети", icon: "figure.2.and.child.holdinghands", iconColor: Color.pink.toHex())
    
    // Финансовые обязательства
    static let loans = Category(title: "Кредиты и долги", icon: "creditcard.fill", iconColor: Color.cyan.toHex())
    static let taxes = Category(title: "Налоги и сборы", icon: "doc.plaintext.fill", iconColor: Color.red.toHex())
    
    // Прочее
    static let other = Category(title: "Прочее", icon: "questionmark.circle.fill", iconColor: Color.blue.toHex())
    
    static let allCategories: [Category] = [
        groceries, cafes, clothing, transport, housing, household, pets, gifts, internet,
        health, pharmacy, fitness, personalCare, education, work, entertainment, travel,
        hobby, children, loans, taxes, other
    ]
}

#Preview {
    MainScreenView()
}

#Preview {
    CategoryGridView(selectedCategory: .constant(Category(title: "Аптека", icon: "", iconColor: Color.red.toHex())))
}

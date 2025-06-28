//
//  CategoryViewModel.swift
//  ExpenseManager
//
//  Created by User on 28.03.2025.
//

import Foundation
import SwiftUI

class CategoryViewModel: ObservableObject {
    
    static let shared = CategoryViewModel()
    private init() { loadCategories() }
    
    @Published var searchText: String = ""
    
    let iconSections: [IconSection] = [
        IconSection(title: "Финансы и работа", icons: [
            "dollarsign.circle.fill",
            "creditcard.fill",
            "doc.plaintext.fill",
            "briefcase.fill",
            "chart.bar.fill",
            "banknote.fill",
            "building.2.fill",
            "calendar.badge.clock"
        ]),
        
        IconSection(title: "Покупки и повседневные расходы", icons: [
            "cart.fill",
            "cup.and.saucer.fill",
            "tshirt.fill",
            "wrench.and.screwdriver.fill",
            "gift.fill",
            "basket.fill",
            "bag.fill",
            "shippingbox.fill"
        ]),
        
        IconSection(title: "Дом и жильё", icons: [
            "house.fill",
            "wifi",
            "pawprint.fill",
            "lightbulb.fill",
            "bed.double.fill",
            "sofa.fill",
            "fanblades.fill",
            "hammer.fill"
        ]),
        
        IconSection(title: "Транспорт", icons: [
            "car.fill",
            "bicycle",
            "bus.fill",
            "fuelpump.fill",
            "scooter",
            "car.2.fill",
            "steeringwheel",
            "tram.fill"
        ]),
        
        IconSection(title: "Здоровье и уход", icons: [
            "cross.case.fill",
            "pills.fill",
            "figure.run.circle.fill",
            "scissors",
            "heart.fill",
            "bandage.fill",
            "stethoscope",
            "drop.fill"
        ]),
        
        IconSection(title: "Образование и развитие", icons: [
            "book.fill",
            "graduationcap.fill",
            "pencil.and.outline",
            "brain.head.profile",
            "books.vertical.fill",
            "globe",
            "lightbulb",
            "person.crop.rectangle"
        ]),
        
        IconSection(title: "Досуг и развлечения", icons: [
            "gamecontroller.fill",
            "airplane",
            "paintpalette.fill",
            "film.fill",
            "music.note.house.fill",
            "ticket.fill",
            "theatermasks.fill",
            "camera.fill"
        ]),
        
        IconSection(title: "Дети", icons: [
            "figure.2.and.child.holdinghands",
            "puzzlepiece.fill",
            "book.circle.fill"
        ]),
        
        IconSection(title: "Прочее", icons: [
            "questionmark.circle.fill",
            "ellipsis.circle.fill",
            "sparkles",
            "circle.grid.3x3.fill",
            "gear"
        ])
    ]
    
    
    @Published var categories: [Category] = [
        
        // Основные расходы
        .groceries,
        .cafes,
        .clothing,
        .transport,
        .housing,
        
        // Быт
        .household,
        .pets,
        .gifts,
        .internet,
        
        // Здоровье и красота
        .health,
        .pharmacy,
        .fitness,
        .personalCare,
        
        // Образование и работа
        .education,
        .work,
        
        // Развлечения и досуг
        .entertainment,
        .travel,
        .hobby,
        
        // Дети
        .children,
        
        // Финансовые обязательства
        .loans,
        .taxes,
        
        // Прочее
        .other
    ] {
        didSet {
            saveCategories()
        }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "categories") {
            do {
                categories = try JSONDecoder().decode([Category].self, from: data)
            } catch {
                print("Не удалось загрузить категории: \(error)")
            }
        }
    }
    
    private func saveCategories() {
        do {
            let data = try JSONEncoder().encode(categories)
            UserDefaults.standard.set(data, forKey: "categories")
        } catch {
            print("Не удалось сохранить категории: \(error)")
        }
    }
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func getRandomColor() -> String {
        let colors: [String] = [Color.red.toHex(), Color.blue.toHex(), Color.orange.toHex(), Color.brown.toHex(), Color.cyan.toHex(), Color.pink.toHex()
        ]
        return colors.randomElement()!
    }
}


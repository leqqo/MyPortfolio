//
//  Category.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Equatable, Hashable {
    
    var id = UUID()
    var title: String
    var icon: String
    let iconColor: String
}

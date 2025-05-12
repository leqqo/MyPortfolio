//
//  Task.swift
//  ToDoList
//
//  Created by User on 09.04.2025.
//

import Foundation
import SwiftUI

struct Task: Identifiable, Codable {
    
    var id = UUID()
    var title: String
    var date: Date
    var editingTitle: String = ""
    var isEditing: Bool = false
    var isCompleted: Bool = false
}

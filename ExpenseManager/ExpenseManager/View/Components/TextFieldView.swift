//
//  TextFieldView.swift
//  ExpenseManager
//
//  Created by User on 06.06.2025.
//

import SwiftUI

struct TextFieldView: View {
    
    @Binding var amount: String
    
    var body: some View {
        TextField("Введите сумму", text: $amount)
            .keyboardType(.decimalPad)
            .padding(8)
    }
}


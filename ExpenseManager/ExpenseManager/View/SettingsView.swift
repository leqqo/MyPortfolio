//
//  SettingsView.swift
//  ExpenseManager
//
//  Created by User on 30.03.2025.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        VStack {
            Button(action: {
                MainScreenViewModel.shared.transactions.removeAll()
            }, label: {
                Text("Удалить все транзакции")
            })
        }
    }
}

#Preview {
    SettingsView()
}

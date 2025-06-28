//
//  EditTransactionView.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import SwiftUI

struct EditTransactionView: View {
    
    @ObservedObject private var viewModel: CategoryViewModel = CategoryViewModel.shared
    
    @Environment(\.presentationMode) var presentationMode
    let transaction: Transaction?
    @State private var amount: String
    @State private var category: Category?
    
    init(transaction: Transaction?) {
        self.transaction = transaction
        
        var initialAmount = ""
        var initialCategory: Category?
        
        if let transaction = transaction {
            initialAmount = String(transaction.amount)
            initialCategory = transaction.category
        }
        
        _amount = State(initialValue: initialAmount)
        _category = State(initialValue: initialCategory)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    SearchBar(searchText: $viewModel.searchText)
                    Form {
                        TextFieldView(amount: $amount)
                        CategoryGridView(selectedCategory: $category)
                            .padding(.top, 12)
                    }
                    .opacity(viewModel.filteredCategories.isEmpty ? 0 : 1)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Отмена") {
                                viewModel.searchText = ""
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Сохранить") {
                                updateTransaction()
                            }
                            .disabled(amount.isEmpty || category == nil)
                        }
                    }
                }
                if viewModel.filteredCategories.isEmpty {
                    Text("Ничего не найдено")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
    
    private func updateTransaction() {
        guard let validAmount = Int(amount), let selectedCategory = category else { return }
        guard let transactionID = transaction?.id,
              let index = MainScreenViewModel.shared.transactions.firstIndex(where: { $0.id == transactionID }) else { return }
        
        var updatedTransaction = MainScreenViewModel.shared.transactions[index]
        updatedTransaction.amount = validAmount
        updatedTransaction.category.title = selectedCategory.title
        updatedTransaction.category.icon = selectedCategory.icon
        
        MainScreenViewModel.shared.transactions[index] = updatedTransaction
        
        viewModel.searchText = ""
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    EditTransactionView(transaction: Transaction(amount: 150, category: Category(title: "Продукты", icon: "cart", iconColor: Color.red.toHex())))
}

#Preview {
    MainScreenView()
}

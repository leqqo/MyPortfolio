//
//  AddExpenseView.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import SwiftUI

struct AddExpenseView: View {
    
    @ObservedObject private var viewModel: CategoryViewModel = CategoryViewModel.shared
    
    @Environment(\.presentationMode) var presentationMode
    @State private var amount = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    SearchBar(searchText: $viewModel.searchText)
                    Form {
                        TextFieldView(amount: $amount)
                        CategoryGridView(selectedCategory: $selectedCategory)
                            .padding(.top, 12)
                    }
                    .opacity(viewModel.filteredCategories.isEmpty ? 0 : 1)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Отмена") {
                                viewModel.searchText = ""
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundStyle(.red)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            
                            Button("Добавить") {
                                addTransaction()
                            }
                            .disabled(amount.isEmpty || selectedCategory == nil)
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
    
    func addTransaction() {
        if let category = selectedCategory {
            let transaction = Transaction(amount: -Int(amount)!, category: category)
            MainScreenViewModel.shared.transactions.append(transaction)
        }
        viewModel.searchText = ""
        presentationMode.wrappedValue.dismiss()
    }
    
    func categoryChecker(_ amount: String, category: Category) -> Int {
        switch category.title {
        case "Зарплата": return +Int(amount)!
        default:
            return -Int(amount)!
        }
    }
}

#Preview {
    AddExpenseView()
}

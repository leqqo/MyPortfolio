//
//  MainScreenView.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import SwiftUI
import Foundation

struct MainScreenView: View {
    
    @ObservedObject var viewModel = MainScreenViewModel.shared
    
    @State private var showAddExpense: Bool = false
    @State private var showActionSheet: Bool = false
    @State var showEditView: Bool = false
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ChartContentView()
                    TransactionHistoryView(viewModel: viewModel, selectedTransaction: $selectedTransaction, showActionSheet: $showActionSheet)
                        .padding(.horizontal)
                        .confirmationDialog("Выберите действие", isPresented: $showActionSheet, titleVisibility: .hidden) {
                            Button("Редактировать") {
                                showEditView = true
                            }
                            Button("Удалить", role: .destructive) {
                                deleteTransaction(transaction: selectedTransaction)
                            }
                            Button("Отмена", role: .cancel) { }
                        }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddExpense = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                    }
                }
                .applyDefaultNavigationBarStyle()
                .sheet(isPresented: $showEditView) {
                    EditTransactionView(transaction: selectedTransaction)
                }
            }
        }
        .sheet(isPresented: $showAddExpense, content: {
            AddExpenseView()
        })
    }
    
    func editTransaction(transaction: Transaction?) {
        guard transaction != nil else { return }
        showEditView.toggle()
    }
    
    func deleteTransaction(transaction: Transaction?) {
        guard let transaction = transaction else { return }
        if let index = viewModel.transactions.firstIndex(where: { $0.id == transaction.id }) {
            viewModel.transactions.remove(at: index)
        }
    }
}

#Preview {
    MainScreenView()
}

struct HStackView: View {
    
    var transaction: Transaction
    
    var body: some View {
        HStack {
            Label(title: {
                Text(transaction.category.title)
            }, icon: {
                Image(systemName: transaction.icon)
                    .foregroundStyle(Color.fromHex(transaction.category.iconColor))
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .padding(.trailing, 2)
            })
            Spacer()
            Text(transaction.amount.formatAmount())
                .fontWeight(.medium)
        }
    }
}

struct TransactionHistoryView: View {
    
    @ObservedObject var viewModel: MainScreenViewModel
    @Binding var selectedTransaction: Transaction?
    @Binding var showActionSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Последние транзакции")
                .font(.title)
            LazyVStack(spacing: 22) {
                ForEach(viewModel.groupedTransactions, id: \.key) { key, dayTransactions in
                    Section(header: Text(key)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    ) {
                        ForEach(dayTransactions) { transaction in
                            HStackView(transaction: transaction)
                                .background(Color(uiColor: .systemBackground))
                                .onTapGesture {
                                    selectedTransaction = transaction
                                    showActionSheet.toggle()
                                }
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

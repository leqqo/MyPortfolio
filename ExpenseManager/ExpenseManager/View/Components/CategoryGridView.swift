//
//  CategoryGridView.swift
//  ExpenseManager
//
//  Created by User on 26.03.2025.
//

import SwiftUI

struct CategoryGridView: View {
    
    @ObservedObject private var viewModel: CategoryViewModel = CategoryViewModel.shared
    
    @Binding var selectedCategory: Category?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.filteredCategories) { category in
                    Button(action: {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .frame(width: 46, height: 46)
                                .foregroundStyle(Color.fromHex(category.iconColor))
                            Text(category.title)
                                .foregroundStyle(.primary)
                        }
                        .padding(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedCategory?.title == category.title ? Color.gray.opacity(0.1) : Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    CategoryGridView(selectedCategory: .constant(Category(title: "Аптека", icon: "", iconColor: Color.red.toHex())))
}

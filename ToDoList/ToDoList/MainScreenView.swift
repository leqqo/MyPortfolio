//
//  ContentView.swift
//  ToDoList
//
//  Created by User on 09.04.2025.
//

import SwiftUI
import UIKit
import SwipeActions
import Combine

struct MainScreenView: View {
    
    @StateObject private var viewModel = MainScreenViewModel()
    
    @State private var taskText: String = ""
    @State private var isEditing = false
    @FocusState private var focusedTaskID: UUID?
    @State private var openSwipeID: UUID?
    @State private var editingTaskID: UUID?
    @State private var titleErrors: [UUID: Bool] = [:]
    
    private let swipePublisher = PassthroughSubject<UUID?, Never>()
    
    var body: some View {
        
        VStack(spacing: 24) {
            addTaskView
            DatePicker("Выберите дату", selection: $viewModel.selectedDate)
                .datePickerStyle(.compact)
            addButtonView
            dateNavigationView
            
            GeometryReader { geometry in
                ScrollView {
                    if viewModel.groupedTasksByHour.isEmpty {
                        emptyTasksView(geometry: geometry)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.groupedTasksByHour, id: \.0) { hour, tasksForHour in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(hour)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 2)
                                        .frame(height: 24)
                                    VStack {
                                        ForEach(tasksForHour) { task in
                                            TaskRowView(
                                                task: task,
                                                viewModel: viewModel,
                                                titleErrors: $titleErrors,
                                                focusedTaskID: $focusedTaskID,
                                                editingTaskID: $editingTaskID,
                                                openSwipeID: $openSwipeID,
                                                swipePublisher: swipePublisher
                                            )
                                        }
                                    }
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(.horizontal)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    var addButtonView: some View {
        Button(action: {
            if !taskText.isEmpty && taskText.count > 2 {
                
                let task = Task(title: taskText, date: viewModel.selectedDate)
                viewModel.tasks.append(task)
                taskText = ""
            }
            
        }) {
            Text("Добавить")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .fontWeight(.medium)
                .cornerRadius(12)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var addTaskView: some View {
        TextField("Введите задачу", text: $taskText)
            .padding(12)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .padding(.top, 8)
    }
    
    @ViewBuilder
    var dateNavigationView: some View {
        HStack {
            Button {
                if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.currentDate) {
                    viewModel.currentDate = newDate
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Text(dateString(from: viewModel.currentDate))
            
            Button {
                if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.currentDate) {
                    viewModel.currentDate = newDate
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    @ViewBuilder
    func emptyTasksView(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            Text("Задачи отсутствуют")
                .font(.title3)
                .foregroundStyle(Color(UIColor.systemGray))
            Spacer()
        }
        .frame(minHeight: geometry.size.height / 2)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainScreenView()
}


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

struct MainScreen: View {
    
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
            TextField("Введите задачу", text: $taskText)
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.top, 8)
            
            DatePicker("Выберите дату", selection: $viewModel.selectedDate)
                .datePickerStyle(.compact)
            
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
            
            HStack {
                Button {
                    if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
                        viewModel.selectedDate = newDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Text(dateString(from: viewModel.selectedDate))
                
                Button {
                    
                    if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
                        viewModel.selectedDate = newDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            
            GeometryReader { geometry in
                ScrollView {
                    if viewModel.groupedTasksByHour.isEmpty {
                        VStack {
                            Spacer()
                            Text("Задачи отсутствуют")
                                .font(.title3)
                                .foregroundStyle(Color(UIColor.systemGray))
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height / 2)
                        .frame(maxWidth: .infinity)
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
                                                SwipeView {
                                                    if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                                        HStack {
                                                            if viewModel.tasks[index].isEditing {
                                                                TextField("", text: $viewModel.tasks[index].editingTitle)
                                                                    .frame(height: 20)
                                                                    .focused($focusedTaskID, equals: task.id)
                                                                    .onSubmit {
                                                                        let newTitle = viewModel.tasks[index].editingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                                                                        if newTitle.count >= 3 {
                                                                            viewModel.tasks[index].title = newTitle
                                                                            viewModel.tasks[index].isEditing = false
                                                                            titleErrors[task.id] = false
                                                                        } else {
                                                                            titleErrors[task.id] = true
                                                                            focusedTaskID = task.id
                                                                        }
                                                                    }
                                                                
                                                                if titleErrors[task.id] == true {
                                                                    Text("Минимум 3 символа")
                                                                        .font(.subheadline)
                                                                        .foregroundColor(.red)
                                                                }
                                                            } else {
                                                                Text(viewModel.tasks[index].title)
                                                                    .foregroundColor(.primary)
                                                                    .frame(height: 20)
                                                                Spacer()
                                                            }
                                                        }
                                                        .padding(12)
                                                        .contentShape(RoundedRectangle(cornerRadius: 12))
                                                    }
                                                } trailingActions: { context in
                                                    SwipeAction("Изменить") {
                                                        focusedTaskID = task.id
                                                        if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                                            viewModel.tasks[index].editingTitle = viewModel.tasks[index].title
                                                            viewModel.tasks[index].isEditing.toggle()
                                                            editingTaskID = task.id
                                                        }
                                                        context.state.wrappedValue = .closed
                                                    }
                                                    .onReceive(swipePublisher) { id in
                                                        if id != task.id {
                                                            context.state.wrappedValue = .closed
                                                            
                                                            if let previousID = editingTaskID,
                                                               let index = viewModel.tasks.firstIndex(where: { $0.id == previousID }) {
                                                                viewModel.tasks[index].isEditing = false
                                                            }
                                                            editingTaskID = id
                                                        }
                                                    }
                                                    
                                                    .onChange(of: context.state.wrappedValue) { _, newValue in
                                                        if newValue == .expanded {
                                                            openSwipeID = task.id
                                                            swipePublisher.send(task.id)
                                                        }
                                                    }
                                                    
                                                    SwipeAction("Выполнено") {
                                                        if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                                            viewModel.tasks.remove(at: index)
                                                        }
                                                    }
                                                    .background(.green)
                                                    .foregroundStyle(.white)
                                                }
                                                .swipeActionWidth(115)
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
    
    private func binding(for task: Task) -> Binding<String>? {
        guard let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) else {
            return nil
        }
        return $viewModel.tasks[index].title
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    MainScreen()
}


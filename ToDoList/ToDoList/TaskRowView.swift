//
//  TaskRowView.swift
//  ToDoList
//
//  Created by User on 26.05.2025.
//

import SwiftUI
import SwipeActions
import Combine

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: MainScreenViewModel

    @Binding var titleErrors: [UUID: Bool]
    @FocusState.Binding var focusedTaskID: UUID?
    @Binding var editingTaskID: UUID?
    @Binding var openSwipeID: UUID?

    let swipePublisher: PassthroughSubject<UUID?, Never>

    var body: some View {
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



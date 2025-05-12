//
//  MainScreenViewModel.swift
//  ToDoList
//
//  Created by User on 10.04.2025.
//

import Foundation

class MainScreenViewModel: ObservableObject {
    
    init() {
        loadTasks()
    }
    
    @Published var tasks = [Task]() {
        didSet {
            saveTasks()
        }
    }
    
    @Published var selectedDate: Date = Date()
    
    var groupedTasksByHour: [(String, [Task])] {
        let filteredTasks = tasks.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        let grouped = Dictionary(grouping: filteredTasks) { task in
            let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
            return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
        }

        return grouped.sorted { $0.key < $1.key }
    }

    
    func tasks(for timeString: String) -> [Task] {
        return tasks.filter { task in
            guard Calendar.current.isDate(task.date, inSameDayAs: selectedDate) else { return false }
            let components = Calendar.current.dateComponents([.hour, .minute], from: task.date)
            if let hour = components.hour, let minute = components.minute {
                let taskTime = String(format: "%02d:%02d", hour, minute)
                return taskTime == timeString
            }
            return false
        }
    }
    
    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: "tasks")
        } catch {
            print("Ошибка при сохранении задач: \(error)")
        }
    }
    
    func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: "tasks") else { return }
        do {
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("Ошибка при загрузке задач: \(error)")
        }
    }
}

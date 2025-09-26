//
//  CalendarView.swift
//  ExpenseManager
//
//  Created by User on 02.04.2025.
//

import SwiftUI

struct CalendarView: View {
    
    @ObservedObject var viewModel = CalendarViewModel.shared
    
    let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            VStack {
                changeYear
                weekDays
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 46) {
                            // Группируем по месяцу, используя второй элемент кортежа (Date)
                            let groupedByMonth = Dictionary(
                                grouping: viewModel.getDaysInYear(),
                                by: { calendar.component(.month, from: $0.1) } // берём месяц из Date
                            )
                            
                            ForEach(1...12, id: \.self) { monthIndex in
                                if let items = groupedByMonth[monthIndex] {
                                    VStack(alignment: .leading) {
                                        // Название месяца
                                        monthHeader(month: calendar.monthSymbols[monthIndex - 1],
                                                    index: monthIndex - 1)
                                        
                                        // Вытаскиваем только Date из (String, Date) и сортируем
                                        let dates = items.map { $0.1 }.sorted()
                                        calendarGrid(dates: dates, calendar: calendar)
                                    }
                                }
                            }
                        }
                        .padding()
                    }


                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.scrollToCurrentMonth(scrollViewProxy: proxy)
                        }
                    }
                    .onChange(of: viewModel.currentYear) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.scrollToCurrentMonth(scrollViewProxy: proxy)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        viewModel.setCurrentMonthRange()
                        viewModel.isCalendarShow = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.isCalendarShow = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var changeYear: some View {
        HStack {
            Button(action: { viewModel.changeYear(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            
            Text(viewModel.currentYear, format: .dateTime.year())
                .font(.headline)
            
            Button(action: { viewModel.changeYear(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    
    var weekDays: some View {
        // исходные сокращённые имена дней
        let weekDays = calendar.shortWeekdaySymbols
        
        // сдвиг массива в зависимости от firstWeekday
        let shifted = Array(weekDays[calendar.firstWeekday-1..<weekDays.count] + weekDays[0..<calendar.firstWeekday-1])
        
        return HStack {
            ForEach(shifted, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func monthHeader(month: String, index: Int) -> some View {
        HStack {
            Spacer().frame(width: 12)
            Text(month)
                .font(.headline)
                .foregroundStyle(.blue)
                .bold()
                .padding(.bottom, 12)
                .id(index + 1)
        }
    }
    
    
    func calendarGrid(dates: [Date], calendar: Calendar) -> some View {
        let firstDay = dates.first!
        let weekday = calendar.component(.weekday, from: firstDay) // 1 = Sunday, 2 = Monday...
        
        // Определяем сколько пустых ячеек нужно перед числами
        let leadingEmptyDays = (weekday - calendar.firstWeekday + 7) % 7
        
        // Общий массив: пустые слоты + реальные даты
        let items: [Date?] = Array(repeating: nil, count: leadingEmptyDays) + dates
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(0..<items.count, id: \.self) { index in
                if let date = items[index] {
                    Button(action: { viewModel.selectDate(date) }) {
                        Text("\(calendar.component(.day, from: date))")
                            .frame(width: 40, height: 40)
                            .background(viewModel.getColor(for: "background", date: date))
                            .clipShape(Circle())
                            .foregroundColor(viewModel.getColor(for: "foreground", date: date))
                    }
                } else {
                    // пустая ячейка
                    Text("")
                        .frame(width: 40, height: 40)
                }
            }
        }
    }

}

#Preview {
    CalendarView()
}

#Preview {
    MainScreenView()
}

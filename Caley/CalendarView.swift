//
//  CalendarView.swift
//  Caley
//
//  Created by Rigels H on 2024-09-05.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: true)],
        animation: .default)
    private var workouts: FetchedResults<Workout>
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: IdentifiableDate? = nil
    @State private var showWorkoutDetail = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ZStack {
            // Adjusted gradient with more green
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.white]),
                           startPoint: .top,
                           endPoint: .center)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Month navigation with white chevrons
                HStack {
                    Button(action: {
                        changeMonth(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Text(currentMonthFormatted)
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        changeMonth(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Days of the week row with unique IDs
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                        Text(day)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)

                // Calendar area
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .frame(maxHeight: 320)

                    LazyVGrid(columns: columns, spacing: 10) {
                        let days = daysInMonthWithOffset()
                        ForEach(days.indices, id: \.self) { index in
                            if let date = days[index] {
                                let workoutForDay = workouts.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date) }
                                let workoutCount = workoutForDay.count

                                Button(action: {
                                    selectedDate = IdentifiableDate(date: date)
                                    showWorkoutDetail = true
                                }) {
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(getColor(for: workoutCount))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 1)
                                        )
                                }
                            } else {
                                // Placeholder for empty grid cells
                                Text("")
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }

                Spacer()

                Text("You have done \(workoutsThisWeek()) workouts this week")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.bottom)

                Spacer()

                // Sheet to present workout details
                .sheet(isPresented: Binding(
                    get: { showWorkoutDetail && selectedDate != nil },
                    set: { _ in showWorkoutDetail = false })
                ) {
                    if let identifiableDate = selectedDate {
                        WorkoutDetailView(selectedDate: identifiableDate.date)
                            .environment(\.managedObjectContext, viewContext)
                    }
                }
            }
        }
        .onAppear {
            selectedDate = nil
            showWorkoutDetail = false
        }
    }

    // MARK: - Month Navigation
    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    var currentMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    // MARK: - Days Calculation
    func daysInMonthWithOffset() -> [Date?] {
        let calendar = Calendar.current
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1 // Subtract 1 to match zero-based index
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday) // Fill empty slots for the first week
        days += (1...range.count).compactMap { day -> Date? in
            let components = DateComponents(year: calendar.component(.year, from: currentMonth),
                                            month: calendar.component(.month, from: currentMonth),
                                            day: day)
            return calendar.date(from: components)
        }
        return days
    }

    // MARK: - Weekly Workout Count
    func workoutsThisWeek() -> Int {
        let today = Date()
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!

        let workoutsInWeek = workouts.filter { workout in
            if let date = workout.date {
                return date >= startOfWeek && date <= endOfWeek
            }
            return false
        }
        return workoutsInWeek.count
    }

    // MARK: - Color for Workout Days
    func getColor(for workoutCount: Int) -> Color {
        return workoutCount > 0 ? Color.green.opacity(min(Double(workoutCount) / 2.0, 1.0)) : Color.gray.opacity(0.2)
    }
}

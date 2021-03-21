//
//  Workout.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import Foundation

struct Workout: Identifiable {
    var id = UUID()
    var caloriesBurned: Double
    var date: Date
    var categories: String
    var duration: Int
    
    static let dateFormatter: DateFormatter = {
        let locale = Locale.autoupdatingCurrent
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let exampleWorkouts = [
        Workout(caloriesBurned: Double(Int.random(in: 50...2000)), date: Date(), categories: "HIIT", duration: 20 ),
        Workout(caloriesBurned: Double(Int.random(in: 50...2000)), date: Date(),categories: "YOGA", duration: 20),
        Workout(caloriesBurned: Double(Int.random(in: 50...2000)), date: Date().advanced(by: Measurement(value: -48, unit: UnitDuration.hours).converted(to: .seconds).value),categories: "YOGA", duration: 20),
        Workout(caloriesBurned: Double(Int.random(in: 50...2000)), date: Date().advanced(by: Measurement(value: -72, unit: UnitDuration.hours).converted(to: .seconds).value),categories: "YOGA", duration: 200),
        Workout(caloriesBurned: Double(Int.random(in: 50...2000)), date: Date().advanced(by: Measurement(value: -96, unit: UnitDuration.hours).converted(to: .seconds).value),categories: "YOGA", duration: 20),
    ]
}

// MARK: - View Model

extension Workout {
    var weekdaySymbol: String {
//        Self.dateFormatter.shortWeekdaySymbols
        return Self.dateFormatter.shortWeekdaySymbols[Calendar.autoupdatingCurrent.component(.weekday, from: date) - 1]
    }
    var dateDescription: String {
        return Self.dateFormatter.string(from: date)
    }
}


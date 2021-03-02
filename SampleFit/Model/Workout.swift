//
//  Workout.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import Foundation

struct Workout: Identifiable {
    var id = UUID()
    var caloriesBurned: Int
    var date: Date
    
    static let dateFormatter: DateFormatter = {
        let locale = Locale.autoupdatingCurrent
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let exampleWorkouts = [
        Workout(caloriesBurned: Int.random(in: 50...2000), date: Date()),
        Workout(caloriesBurned: Int.random(in: 50...2000), date: Date().advanced(by: Measurement(value: -24, unit: UnitDuration.hours).converted(to: .seconds).value)),
        Workout(caloriesBurned: Int.random(in: 50...2000), date: Date().advanced(by: Measurement(value: -48, unit: UnitDuration.hours).converted(to: .seconds).value)),
        Workout(caloriesBurned: Int.random(in: 50...2000), date: Date().advanced(by: Measurement(value: -72, unit: UnitDuration.hours).converted(to: .seconds).value)),
        Workout(caloriesBurned: Int.random(in: 50...2000), date: Date().advanced(by: Measurement(value: -96, unit: UnitDuration.hours).converted(to: .seconds).value)),
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


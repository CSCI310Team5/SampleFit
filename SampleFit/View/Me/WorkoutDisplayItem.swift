//
//  WorkoutDisplayItem.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct WorkoutDisplayItem: View {
    var workout: Workout
    
    func asString(second: Int) -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(second))!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // top row
            
            HStack {
                HStack {
                    Image(systemName: "flame.fill")
                    Text(workout.weekdaySymbol)
                        .textCase(.uppercase)
                }
                .font(Font.subheadline.bold())
                .foregroundColor(.workoutLabelColor)
                
                Spacer()
                
                Text(workout.dateDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // bottom
            HStack {
                Text(workout.categories).font(.body)
                Text("\(asString(second: workout.duration))").font(.callout).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                
                Spacer()
                
                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                        Text("\(String(format: "%.2f", workout.caloriesBurned) )")
                            .font(Font.system(.title2, design: .rounded).weight(.semibold))
                        Text("cal")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
            }
        }
        .padding(.vertical, 8)
    }
}

struct WorkoutDisplayItem_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            List {
                Section {
                    WorkoutDisplayItem(workout: Workout.exampleWorkouts[0])
                    WorkoutDisplayItem(workout: Workout.exampleWorkouts[1])
                    WorkoutDisplayItem(workout: Workout.exampleWorkouts[2])
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}

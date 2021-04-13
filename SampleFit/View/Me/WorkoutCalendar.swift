//
//  WorkoutCalendar.swift
//  SampleFit
//
//  Created by Zihan Qi on 4/12/21.
//

import SwiftUI
import EventKit

struct WorkoutCalendar: View {
    @ObservedObject var privateInformation: PrivateInformation
    @State private var selectedDate = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    @State private var isAddCalendarWorkoutSheetPresented = false
    
    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(20)
            
            Divider()
            
            VStack(spacing: 8) {
                Text("\(selectedDate, formatter: dateFormatter)")
                    .font(.headline)
                    .textCase(.uppercase)
                .padding(.horizontal)
                
                WorkoutHistoryList(workoutHistory: privateInformation.workoutHistory(for: selectedDate))
                    .padding(.vertical, 20)
            }
            
            Spacer()
        }
        .sheet(isPresented: $isAddCalendarWorkoutSheetPresented) {
            AddCalendarWorkoutView(isPresented: $isAddCalendarWorkoutSheetPresented, selectedDate: selectedDate)
        }
        .navigationBarItems(trailing:
            Button(action: presentAddCalendarWorkoutSheet) {
                Image(systemName: "plus")
            }
        )
        .navigationBarTitle("Workout Calendar", displayMode: .inline)
        
    }
    
    func presentAddCalendarWorkoutSheet() {
        isAddCalendarWorkoutSheetPresented = true
        let store = EKEventStore()
        store.requestAccess(to: .event) { (granted, error) in
            #warning("We are currently assuming calendar access is always granted. You should handle cases where access is denied.")
        }
        
    }

}

struct WorkoutCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            WorkoutCalendar(privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}

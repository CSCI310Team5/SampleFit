//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct TestView: View {
    @ObservedObject var privateInformation: PrivateInformation
    @State private var selectedDate = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
            
            Divider()
            
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(selectedDate, formatter: dateFormatter)")
                        .font(.headline)
                        .textCase(.uppercase)
                }
                .padding(.horizontal)
                WorkoutHistoryList(workoutHistory: privateInformation.workoutHistory(for: selectedDate))
            }
            
            Spacer()
        }
        
    }
}


struct TestView_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            TestView(privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}

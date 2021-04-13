//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct TestView: View {
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

            Text("\(selectedDate, formatter: dateFormatter)")
        }
        
    }
}


struct TestView_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        TestView()
    }
}

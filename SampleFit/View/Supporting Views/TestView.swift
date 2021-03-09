//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct TestView: View {
    @State private var selection = 0
        @State private var selection2 = 0
        @State private var selection3 = 0
        let numbers = [Int](1000...1040)

        var body: some View {
            Picker("Number", selection: $selection) {
                ForEach(0..<numbers.count) { index in
                    Text("\(self.numbers[index])")
                }
            }
//            .labelsHidden()
            .frame(width: 20)

        }
}


struct TestView_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        TestView()
    }
}

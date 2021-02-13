//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI


import SwiftUI

struct TestView: View {
    let cars = ["Subaru WRX", "Tesla Model 3", "Porsche 911", "Renault Zoe", "DeLorean", "Mitsubishi Lancer", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6", "Audi RS6"]
    @State private var searchText : String = ""

    var body: some View {
        NavigationView {
//            SearchBar(text: $searchText, placeholder: "Search cars")
            List {
                ForEach(self.cars.filter {
                    self.searchText.isEmpty ? true : $0.lowercased().contains(self.searchText.lowercased())
                }, id: \.self) { car in
                    Text(car)
                }
            }
//            .navigationTitle(Text("Cars"))
            .navigationBarTitle("Cars", displayMode: .large)
            .navigationBarItems(leading: Text("Yoyoyoyoyoyoyoyooyooyoyoyoyyoyoyoyoyoyo"))
//            .navigationBarItems(trailing:SearchBar(text: $searchText, placeholder: "Search cars")
//                                    .frame(width: UIScreen.main.bounds.width * 0.92, height: 100, alignment: .center)
//                                    .padding(.bottom)
//            )
//            .toolbar {
//                ToolbarItemGroup {
//                    SearchBar(text: $searchText, placeholder: "Search cars")
//                        .frame(width: UIScreen.main.bounds.width * 0.92, height: 100, alignment: .center)
//                        .padding(.bottom)
//                }
//            }
        }
        
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

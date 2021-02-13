//
//  BrowseView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct BrowseView: View {
    var allCategoryNames = ["Dance", "Yoga", "HIT", "Cycling", "Power Training"]
    
    var body: some View {
        NavigationView {
            
            List {
                VStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                }
                .listRowInsets(EdgeInsets())
                .overlay(
                    FeaturedExerciseOverlay()
                ,alignment: .bottomLeading)
                
                ForEach(allCategoryNames, id: \.self) { categoryName in
                    ExerciseCategoryRow(categoryName: categoryName)
                        .padding(.top, categoryName == allCategoryNames[0] ? 8 : 0)

                }
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Browse")
            
        }
        
    }
}

struct FeaturedExerciseOverlay: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dance with Abudala Awabel")
                .font(.title3)
                .bold()
            Text("10min")
                .font(.callout)
        }
        .padding()
        
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            BrowseView()
        }
        .environmentObject(userData)
    }
}


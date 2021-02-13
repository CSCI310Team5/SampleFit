//
//  ExerciseCategoryRow.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct ExerciseCategoryRow: View {
    var categoryName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            // category name label
            Text(categoryName)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.leading, 15)
            
            // horizontal scroll view
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<6) { index in
                        ExerciseCategoryItem()
                            // padding on the last item so that it doesn't look shifted
                            .padding(.trailing, index == 5 ? UIScreen.main.bounds.width * 0.075 : 0)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .padding(.bottom)
    }
}

struct ExerciseCategoryRow_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            VStack {
                ExerciseCategoryRow(categoryName: "Category 1")
                ExerciseCategoryRow(categoryName: "Category 2")
            }
            
        }
        .environmentObject(userData)
    }
}

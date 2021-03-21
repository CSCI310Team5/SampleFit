//
//  ExerciseCategoryRow.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct ExerciseCategoryRow: View {
    @EnvironmentObject var privateInformation: PrivateInformation
    @EnvironmentObject var userData: UserData
    var categoryName: String
    var items: [Exercise]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline) {
                // category name label
                Text(categoryName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // show all button
                NavigationLink(destination: ExerciseSearchResultList(exercises: items).navigationTitle(categoryName)) {
                    Text("Show All")
                        .foregroundColor(.accentColor)
                }
                .padding(.trailing, 6)
            }
            
                .padding(.top, 8)
                .padding(.horizontal, 15)
            
            // horizontal scroll view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // show up to 6 items only
                    ForEach(Array(items.prefix(6))) { item in
                        NavigationLink(destination: ExerciseDetail(privateInformation: privateInformation, exercise: item)) {
                            ExerciseListDisplayItem(exercise: item)
                                // padding on the last item so that it doesn't look shifted
                                .padding(.trailing, item == items.last! ? UIScreen.main.bounds.width * 0.075 : 0)
                                .foregroundColor(.primary)
                        }
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
                ExerciseCategoryRow(categoryName: "Category 1", items: Exercise.exampleExercisesAllPushup)
                ExerciseCategoryRow(categoryName: "Category 2", items: Exercise.exampleExercisesAllPushup)
            }
            
        }
        .environmentObject(userData)
        .environmentObject(userData.privateInformation)
    }
}

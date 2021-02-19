//
//  ExerciseList.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/18/21.
//

import SwiftUI

struct ExerciseList: View {
    @ObservedObject var socialInformation: SocialInformation
    
    var body: some View {
        List {
            FeaturedExercisesView(exercises: socialInformation.featuredExercises)
                .listRowInsets(EdgeInsets())
            
//            EmptyView()
//                .padding(.bottom, 8)
            
            // iterating category instead of the actual items to prevent ForEach from making a copy of the items array which could fail in rerendering
            ForEach(Exercise.Category.allCases, id: \.self) { category in
                ExerciseCategoryRow(categoryName: category.description, items: socialInformation.exerciseInCategory[category]!)
                    // forces view update when an exercise in a category changes
//                    .id(socialInformation.updatingTrackerIdForCategory[category])
            }
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle("Browse")
    }
}

struct FeaturedExercisesView: View {
    var exercises: [Exercise]
    var body: some View {
        NavigationLink(destination: ExerciseDetail(exercise: exercises[0])) {
            Group {
                if exercises[0].image != nil {
                    exercises[0].image!
                } else {
                    PlaceholderImage()
                }
            }
            
            .frame(height: 200, alignment: .bottom)
            .frame(maxWidth: .infinity)

            .listRowInsets(EdgeInsets())
            .overlay(
                ZStack(alignment: .bottomLeading) {
                    // gradient
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
                    
                    // text
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercises[0].name)
                            .font(.title3)
                            .bold()
                        if exercises[0].playbackType == .recordedVideo {
                            Text(exercises[0].description)
                                .font(.callout)
                        } else {
                            HStack(spacing: 6) {
                                LiveIndicator()
                                Text(exercises[0].durationDescription)
                                    .font(.callout)
                                    .bold()
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width)
            ,alignment: .bottomLeading)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


struct ExerciseList_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ExerciseList(socialInformation: userData.socialInformation)
        }
        .environmentObject(userData)
    }
}

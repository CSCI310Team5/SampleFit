//
//  ExerciseCategoryRow.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct ExerciseCategoryRow: View {
    var categoryName: String
    var items: [Exercise]
    
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
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: ExerciseDetail(exercise: item)) {
                            ExerciseCategoryItem(item: item)
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

struct ExerciseCategoryItem: View {
    @ObservedObject var item: Exercise
    var body: some View {
        HStack(alignment: .center) {
            Group {
                if item.image != nil {
                    item.image!
                        .resizable()
                        .scaledToFill()
                } else {
                    PlaceholderImage()
                }
            }
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .clipped()
                        
            VStack(alignment: .leading) {
                if item.playbackType == .recordedVideo {
                    Text(item.durationDescription)
                        .font(.caption)
                } else {
                    // live indicator
                    HStack(spacing: 6) {
                        LiveIndicator()
                        Text(item.durationDescription)
                            .font(.caption)
                            .bold()
                    }
                }
                
                Text(item.name)
            }
            
            Spacer()

        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
    }
}


struct ExerciseCategoryRow_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            VStack {
                ExerciseCategoryRow(categoryName: "Category 1", items: Exercise.sampleExercisesAllPushup)
                ExerciseCategoryRow(categoryName: "Category 2", items: Exercise.sampleExercisesAllPushup)
            }
            
        }
        .environmentObject(userData)
    }
}

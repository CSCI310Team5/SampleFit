//
//  ExerciseBrowseView.swift
//  SampleFit
//
//  Created by apple on 3/11/21.
//

import SwiftUI

struct WorkoutBrowseView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var privateInformation: PrivateInformation
    
    
    var body: some View {
        
        let columns=[GridItem(.flexible()),GridItem(.flexible())]
        
        VStack(){
            NavigationView{
                
                LazyVGrid(columns: columns, spacing:15 ){
                    ForEach(Exercise.Category.allCases, id: \.self) { category in
                        
                        if category == Exercise.Category.situp{
                            NavigationLink(destination: SpecialWorkoutView(privateInformation: privateInformation,publicInformation: userData.publicProfile, categoryName:category.description, categoryIndex: category.index)) {
                                CategorySquareView(categoryName: category.description)
                            }
                        }
                        else{
                            NavigationLink(destination: WorkoutView(privateInformation: privateInformation,publicInformation: userData.publicProfile, categoryName:category.description, categoryIndex: category.index)) {
                                CategorySquareView(categoryName: category.description)
                            }
                        }
                    }
                    
                }.position(x:UIScreen.main.bounds.size.width/2, y:150)
                .navigationTitle("Click To Exercise")
            }
        }
    }}


struct WorkoutBrowseView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        Group {
            WorkoutBrowseView(privateInformation: PrivateInformation.examplePrivateInformation).environmentObject(userData)
        }
    }
}

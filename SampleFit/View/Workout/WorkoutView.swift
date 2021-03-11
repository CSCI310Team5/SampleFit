//
//  WorkoutView.swift
//  SampleFit
//
//  Created by apple on 3/11/21.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var privateInformation: PrivateInformation
    var categoryName: String
   
    @State private var isWorkingout = false
    
    var body: some View {
        
        VStack {
            Text("🔥Let's Do \(categoryName)🔥").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
            
            Spacer()
            
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        WorkoutView(categoryName: "Yoga").environmentObject(userData)
            .environmentObject(userData.privateInformation)
    }
}

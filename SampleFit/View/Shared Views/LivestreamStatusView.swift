//
//  LivestreamStatusView.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/21/21.
//

import SwiftUI

struct LivestreamStatusView: View {
    @EnvironmentObject var privateInformation: PrivateInformation
    @Binding var isPresented: Bool
    @ObservedObject var exercise: Exercise
    
    var body: some View {
        VStack(spacing: 8) {
            Text(exercise.isExpired ? "The livestream has ended." : "You are currently In a livestream.")
                .font(.title2)
                .bold()
            
            Text("Host: \(exercise.owningUser.identifier)")
            
            VStack {
                Button("Leave Room", action: quitLivestream)
                .foregroundColor(Color.systemBackground)
                .frame(minWidth: 100, maxWidth: 150)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 7.5)
                        .fill(Color.accentColor)
                )
            }
            .padding()
        }
    }
    
    func quitLivestream() {
        isPresented = false
        exercise.quitLivestream(authenticationToken: privateInformation.authenticationToken, email: privateInformation.email)
    }
}

struct LivestreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            LivestreamStatusView(isPresented: .constant(true), exercise: Exercise.exampleExercisesFull[0])
        }
        .environmentObject(PrivateInformation.examplePrivateInformation)
    }
}

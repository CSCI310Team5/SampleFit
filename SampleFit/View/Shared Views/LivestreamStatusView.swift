//
//  LivestreamStatusView.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/21/21.
//

import SwiftUI

struct LivestreamStatusView: View {
    @Binding var isPresented: Bool
    @ObservedObject var exercise: Exercise
    
    var body: some View {
        VStack(spacing: 8) {
            Text(exercise.isExpired ? "The livestream has ended." : "You are currently In a livestream.")
                .font(.title2)
                .bold()
            
            Text("Host: \(exercise.owningUser.identifier)")
            
            VStack {
                Button("Leave Room") {
                    isPresented = false
                }
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
}

struct LivestreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            LivestreamStatusView(isPresented: .constant(true), exercise: Exercise.exampleExercisesFull[0])
        }
    }
}

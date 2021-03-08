//
//  DetailedProfileSummary.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct DetailedProfileSummary: View {
    var publicProfile: PublicProfile
    var body: some View {
        VStack {
            MiniProfileSummary(publicProfile: publicProfile)
                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                Divider()

                // nickname
                HStack {
                    Text("Nickname")
                    Spacer()
                    if publicProfile.isNicknameSet {
                        Text(publicProfile.nickname)
                    } else {
                        NotSetView()
                    }
                }
                .padding(.horizontal)
                .frame(minHeight: 44)
                
                Divider()
                            
                // birthday
                HStack {
                    Text("Date of Birth")
                    Spacer()
                    if publicProfile.birthdayDescription != nil {
                        Text(publicProfile.birthdayDescription!)
                    } else {
                        NotSetView()
                    }
                    
                    //                    DatePicker("", selection: $publicProfile.birthdayBinding, in: publicProfile.birthdayDateRange, displayedComponents: .date)
                    //                        .datePickerStyle(CompactDatePickerStyle())
                }
                .padding(.horizontal)
                .frame(minHeight: 44)
                
                Divider()
                            
                // height
                HStack {
                    Text("Height")
                    Spacer()
                    if publicProfile.heightDescription != nil {
                        Text(publicProfile.heightDescription!)
                    } else {
                        NotSetView()
                    }
                }
                .padding(.horizontal)
                .frame(minHeight: 44)
                
                Divider()
                            
                // weight
                HStack {
                    Text("Weight")
                    Spacer()
                    if publicProfile.massDescription != nil {
                        Text(publicProfile.massDescription!)
                    } else {
                        NotSetView()
                    }
                }
                .padding(.horizontal)
                .frame(minHeight: 44)
                            
                Divider()
            }
            
            Spacer()
        }
    }
}

struct DetailedProfileSummary_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            DetailedProfileSummary(publicProfile: PublicProfile.exampleProfile)
        }
    }
}

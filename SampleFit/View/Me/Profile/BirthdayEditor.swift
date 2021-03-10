//
//  BirthdayEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct BirthdayEditor: View {
    @ObservedObject var draftProfile: PublicProfile
    var body: some View {
        HStack {
            // fractional width container
            FractionalWidthView(fraction: 0.3) {
                Text("Date of Birth")
            }
            Divider()
            
            if draftProfile.birthdayDescription != nil {
                DatePicker("", selection: $draftProfile.birthdayBinding, in: draftProfile.birthdayDateRange, displayedComponents: .date)
                    .datePickerStyle(DefaultDatePickerStyle())
            } else {
                Button(action: { withAnimation { draftProfile.birthdayBinding = Date() } }) {
                    HStack {
                        Spacer()
                        NotSetView(isEditModeActive: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(Animation.easeInOut)
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}

struct BirthdayEditor_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            BirthdayEditor(draftProfile: PublicProfile.exampleProfile)
        }
    }
}

//
//  MassEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct MassEditor: View {
    @ObservedObject var draftProfile: PublicProfile
    @Binding var pickerVisibility: PickerVisibility

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // fractional width container
                FractionalWidthView(fraction: 0.3) {
                    Text("Weight")
                }
                Divider()
                // mass picker button
                Button(action: { withAnimation {
                        self.pickerVisibility.setTo(.massPicker)
                    if !draftProfile.isMassSet {
                        self.draftProfile.massBinding = self.draftProfile.massRange[draftProfile.massRange.count / 4]
                    }

                    
                } }) {
                    HStack {
                        Spacer()
                        if draftProfile.massDescription != nil {
                            Text(draftProfile.massDescription!)
                        } else {
                            NotSetView(isEditModeActive: true)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
                        
            if pickerVisibility == .massPicker {
                Divider()

                MassPicker(currentSelection: $draftProfile.massBinding, massRange: draftProfile.massRange)
            }
            
        }
        
    }
}

struct MassPicker: View {
    @Binding var currentSelection: Measurement<UnitMass>
    var massRange: [Measurement<UnitMass>]
    
    var body: some View {
        Picker("", selection: $currentSelection) {
            ForEach(0..<massRange.count) { index in
                Text(massRange[index].personMassDescription)
                    .tag(massRange[index])
            }
        }
    }
}

struct MassEditor_Preview: View {
    @State private var pickerVisibility = PickerVisibility.none
    @ObservedObject var draftProfile = PublicProfile.exampleProfile
    var body: some View {
        MultiplePreview(embedInNavigationView: true) {
            MassEditor(draftProfile: draftProfile, pickerVisibility: $pickerVisibility)
        }
    }
}

struct MassEditor_Previews: PreviewProvider {
    static var previews: some View {
        MassEditor_Preview()
    }
}

//
//  HeightEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct HeightEditor: View {
    @ObservedObject var draftProfile: PublicProfile
    @Binding var pickerVisibility: PickerVisibility

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // fractional width container
                FractionalWidthView(fraction: 0.3) {
                    Text("Height")
                }
                Divider()
                // height picker button
                Button(action: { withAnimation {
                    self.pickerVisibility.setTo(.heightPicker)
                    if !draftProfile.isHeightSet {
                        self.draftProfile.heightBinding = self.draftProfile.heightRange[draftProfile.heightRange.count / 3 * 2]
                    }
                } }) {
                    HStack {
                        Spacer()
                        if draftProfile.heightDescription != nil {
                            Text(draftProfile.heightDescription!)
                        } else {
                            NotSetView(isEditModeActive: true)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
            
            if pickerVisibility == .heightPicker {
                Divider()

                HeightPicker(currentSelection: $draftProfile.heightBinding, heightRange: draftProfile.heightRange)
                    .pickerStyle(InlinePickerStyle())
            }
        }
    }
}

struct HeightPicker: View {
    @Binding var currentSelection: Measurement<UnitLength>
    var heightRange: [Measurement<UnitLength>]
    
    var body: some View {
        Picker("", selection: $currentSelection) {
            ForEach(0..<heightRange.count) { index in
                Text(heightRange[index].personHeightDescription)
                    .tag(heightRange[index])
            }
        }
    }
}

struct HeightEditor_Preview: View {
    @State private var pickerVisibility = PickerVisibility.none
    @ObservedObject var draftProfile = PublicProfile.exampleProfile
    var body: some View {
        MultiplePreview(embedInNavigationView: true) {
            HeightEditor(draftProfile: draftProfile, pickerVisibility: $pickerVisibility)
        }
    }
}

struct HeightEditor_Previews: PreviewProvider {
    static var previews: some View {
        HeightEditor_Preview()
    }
}

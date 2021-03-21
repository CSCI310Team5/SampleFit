//
//  ProfileEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

enum PickerVisibility {
    case none
    case heightPicker
    case massPicker
    
    mutating func setTo(_ newValue: PickerVisibility) {
        guard self != newValue else {
            self = .none
            return
        }
        self = newValue
    }
}

struct ProfileEditor: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var originalProfile: PublicProfile
    @ObservedObject var draftProfile: PublicProfile
    @Binding var isEditorPresented: Bool
    @State private var pickerVisibility = PickerVisibility.none
    
    init(publicProfile: PublicProfile, isPresented: Binding<Bool>) {
        self.originalProfile = publicProfile
        self.draftProfile = publicProfile.copy()
        self._isEditorPresented = isPresented
    }
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 70) {
                
                ImageEditor(draftProfile: draftProfile)
                
                VStack(spacing: 0) {
                    Divider()

                    // nickname
                    NicknameEditor(draftProfile: draftProfile)
                    
                    Divider()
                                
                    // birthday
                    BirthdayEditor(draftProfile: draftProfile)
                    
                    Divider()
                                
                    // height
                    HeightEditor(draftProfile: draftProfile, pickerVisibility: $pickerVisibility)
                    
                    Divider()
                                
                    // weight
                    MassEditor(draftProfile: draftProfile, pickerVisibility: $pickerVisibility)

                    Divider()
                    
                }
                
                Spacer()
            }
            .padding(.top, 90)
            
            HStack {
                Button(action: cancelEdit) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: confirmEdit) {
                    Text("Done")
                        .bold()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
        }
    }
    
    func cancelEdit() {
        self.isEditorPresented = false
    }
    
    func confirmEdit() {
        self.originalProfile.update(using: draftProfile, token: userData.token)
        self.isEditorPresented = false
    }
}

struct ProfileEditor_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            ProfileEditor(publicProfile: PublicProfile.exampleProfile, isPresented: .constant(true))
        }
    }
}

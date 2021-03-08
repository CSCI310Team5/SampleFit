//
//  ProfileEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct ProfileEditor: View {
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
    @ObservedObject var draftProfile: PublicProfile
    @State private var pickerVisibility = PickerVisibility.none
    
    init(publicProfile: PublicProfile) {
        self.draftProfile = publicProfile.copy()
    }
    var body: some View {
        VStack(spacing: 70) {
            draftProfile.image
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.25))
            
            VStack(spacing: 0) {
                Divider()

                // nickname
                HStack {
                    // constant width container
                    ZStack(alignment: .leading) {
                        Text("Nickname")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: UIScreen.main.bounds.width * 0.3)
                    }
                    Divider()
                    
                    TextField("", text: $draftProfile.nickname)
                        .frame(minHeight: 44)
                        .multilineTextAlignment(.trailing)
                        .background(    // custom placeholder
                            Group {
                                if !draftProfile.isNicknameSet || draftProfile.nickname.isEmpty {
                                    NotSetView(isEditModeActive: true)
                                }
                            }
                        ,alignment: .trailing)
                }
                .padding(.horizontal)
                .frame(height: 44)
                
                Divider()
                            
                // birthday
                HStack {
                    // constant width container
                    ZStack(alignment: .leading) {
                        Text("Date of Birth")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: UIScreen.main.bounds.width * 0.3)
                    }
                    Divider()

                    if draftProfile.birthdayDescription != nil {
                        DatePicker("", selection: $draftProfile.birthdayBinding, in: draftProfile.birthdayDateRange, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
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
                
                Divider()
                            
                // height
                HStack {
                    // constant width container
                    ZStack(alignment: .leading) {
                        Text("Height")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: UIScreen.main.bounds.width * 0.3)
                    }
                    Divider()
                    // height picker button
                    Button(action: { withAnimation { self.pickerVisibility.setTo(.heightPicker) } }) {
                        HStack {
                            Spacer()
                            if draftProfile.heightDescription != nil {
                                Text(draftProfile.heightDescription!)
                            } else {
                                NotSetView()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 44)
                
                Divider()
                            
                // weight
                HStack {
                    // constant width container
                    ZStack(alignment: .leading) {
                        Text("Weight")
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: UIScreen.main.bounds.width * 0.3)
                    }
                    Divider()
                    // mass picker button
                    Button(action: { withAnimation { self.pickerVisibility.setTo(.massPicker) } }) {
                        HStack {
                            Spacer()
                            if draftProfile.massDescription != nil {
                                Text(draftProfile.massDescription!)
                            } else {
                                NotSetView()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 44)
                            
                Divider()
                
            }
            
            Spacer()
            
        }
        .overlay(
            Group {
                ZStack {
                    switch self.pickerVisibility {
                    case .heightPicker:
                        BlurView(effect: UIBlurEffect(style: .systemThinMaterial))
                        HeightPicker(currentSelection: .constant(1))
                            .padding(.bottom)
                            .layoutPriority(1)
                            .zIndex(1)
                    case .massPicker:
                        BlurView(effect: UIBlurEffect(style: .systemThinMaterial))
                        MassPicker(currentSelection: .constant(1))
                            .padding(.bottom)
                            .layoutPriority(1)
                            .zIndex(2)
                    default:
                        EmptyView()
                    }
                }
            }
        , alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ProfileEditor_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ProfileEditor(publicProfile: PublicProfile.exampleProfile)
                .navigationBarTitle("Profile Details", displayMode: .inline)
        }
    }
}

struct HeightPicker: View {
    var selections: [Int] = []
    @Binding var currentSelection: Int
    
    var body: some View {
        Picker("", selection: .constant(1)) {
            ForEach(0..<10) { i in
                Text("\(i)")
            }
        }
    }
}

struct MassPicker: View {
    var selections: [Int] = []
    @Binding var currentSelection: Int
    
    var body: some View {
        Picker("", selection: .constant(1)) {
            ForEach(0..<10) { i in
                Text("\(i)")
            }
        }
    }
}

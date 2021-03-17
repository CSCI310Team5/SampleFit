//
//  UploadSheetView.swift
//  SampleFit
//
//  Created by apple on 3/17/21.
//

import SwiftUI
import MobileCoreServices



    
struct UploadSheetView: View  {
    
    @ObservedObject var publicProfile: PublicProfile
    
    @Binding var isPresented: Bool
    
    @State private var name=""
    @State private var description=""
    @State private var category = Exercise.Category.hiit
    @State private var playbackType = true
    @State private var isImagePickerPresented = false
    @State private var image = PublicProfile.exampleProfile.image
    @State private var duration = 2
    @State private var peopleLimit = 2
    @State private var contentLink = ""
    @State private var isVideoPickerPresented = false
    @ObservedObject var newUpload: Exercise = Exercise(id: Int.random(in: Int.min...Int.max), name: "", description: "", category: .pushup, playbackType: .live, owningUser: PublicProfile.exampleProfile, duration: Measurement(value: 2, unit: UnitDuration.minutes), previewImageIdentifier: "", peoplelimt: 0, contentlink: "")
    
    let pickerController = UIImagePickerController()
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", action: { isPresented = false })
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("Confirm").bold()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("Create Livestream Or Upload Video").bold()
            NavigationView{
                Form{
                   
                    HStack {
                        Text("Profile Image Preview")
                        Spacer()
                        image.resizable().frame(width: 100, height: 100, alignment: .trailing).padding()
                    }
                    
                    
                        Toggle(isOn: $playbackType) {
                            Text("LiveStream")
                        }
                        
                        Button("Add Profile Image"){
                            isImagePickerPresented.toggle()
                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(image: $image, isPresented: $isImagePickerPresented)
                        }
                    
                        
                        TextField("Name",text:$name)
                        
                        TextField("Description",text:$description)
                        
                        Picker(selection: $category, label: Text("Exercise Category")) {
                            ForEach(Exercise.Category.allCases, id: \.self) {
                                Text($0.description)
                            }
                        }
                        
                        Picker(selection: $duration, label: Text("Time Length")){
                            ForEach(1...40, id: \.self) {
                                Text("\($0) Min")
                            }
                        }
                    
                    if playbackType{
                        Picker(selection: $peopleLimit, label: Text("People Limit")){
                            ForEach(1...50, id: \.self) {
                                Text("\($0) People")
                            }
                        }
                        
                        TextField("LiveStream Link",text:$contentLink)
                    }
                    else{
//                        Button("Add Video"){
//                            isVideoPickerPresented.toggle()
//                        }
//                        .sheet(isPresented: $isVideoPickerPresented) {
//                            let picker = UIImagePickerController()
//                            picker
//                        }
                    }
                }
            }
            Spacer()
        }
        
    }
}

struct UploadSheetView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        UploadSheetView(publicProfile: PublicProfile.exampleProfile , isPresented: .constant(false))
    }
    
}

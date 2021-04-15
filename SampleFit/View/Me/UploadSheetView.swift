//
//  UploadSheetView.swift
//  SampleFit
//
//  Created by apple on 3/17/21.
//

import SwiftUI
import MobileCoreServices
import Combine
import Foundation



struct UploadSheetView: View  {
    
    @ObservedObject var publicProfile: PublicProfile
    @EnvironmentObject var userData: UserData
    @Binding var isPresented: Bool
    
    @State private var name=""
    @State private var description=""
    @State private var category = Exercise.Category.hiit
    @State private var isLivestream = false
    @State private var isImagePickerPresented = false
    @State private var image = PublicProfile.exampleProfile.image
    @State private var duration = 2
    @State private var peopleLimit = 2
    @State private var contentLink = ""
    @State private var isVideoPickerPresented = false
    @State private var isVideoLoading = false
    @State private var videoURL: URL?
    @State private var comment = false
    
    @ObservedObject var newUpload: Exercise = Exercise(id: String(Int.random(in: Int.min...Int.max)), name: "", description: "", category: .pushup, playbackType: .live, owningUser: PublicProfile.exampleProfile, duration: Measurement(value: 2, unit: UnitDuration.minutes), previewImageIdentifier: "", peoplelimt: 0, contentlink: "")
    
    let pickerController = UIImagePickerController()
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", action: { isPresented = false })
                Spacer()
                Button(action: {
                    newUpload.owningUser=publicProfile
                    newUpload.name=name
                    newUpload.category=category
                    newUpload.description=description
                    newUpload.duration=Measurement(value: Double(duration), unit: UnitDuration.minutes)
                    if isLivestream{
                        newUpload.playbackType =  Exercise.PlaybackType.live
                        newUpload.contentLink=contentLink
                        newUpload.peopleLimit=peopleLimit
                        newUpload.startLivestreamTimer()
                    }else{
                        newUpload.playbackType = Exercise.PlaybackType.recordedVideo
                        newUpload.image=image
                        newUpload.contentLink = videoURL!.absoluteString
                        newUpload.comment=comment
                    }
                    publicProfile.createExercise(newExercise: newUpload, token: userData.token)
                    isPresented = false
                }) {
                    Text("Confirm").bold()
                }.disabled( name.isEmpty || name.count > 25 || description.isEmpty || (image == PublicProfile.exampleProfile.image && !isLivestream) || (isLivestream && contentLink.isEmpty))
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("Create Livestream Or Upload Video").bold()
            
            NavigationView{
                
                Form{
                  
                    HStack {
                        Text("Media Type")
                        Spacer()
                        Text("Video")
                        Toggle("", isOn: $isLivestream)
                            .labelsHidden()
                            .accessibility(localIdentifier: .uploadMediaTypeToggle)
                        Text("Livestream")
                    }
                    
                    
                    if !isLivestream {
                        HStack {
                            Text("Preview Image")
                            Spacer()
                            if image != nil {
                                Image(uiImage: image!)
                                    .resizable().scaledToFit()
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable().scaledToFit()
                            }

                        }.frame(height: 100)
                        
                        Button("Add Preview Image") {
                            isImagePickerPresented.toggle()
                        }
                        Group {
                            HStack {
                                Button("Upload Video") {
                                    isVideoPickerPresented = true
                                }
                                
                                Spacer()
                                
                                if isVideoLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    if videoURL != nil {
                                        Text(videoURL!.lastPathComponent)
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Text("Comment Allowed")
                            Spacer()
                            Text("No")
                            Toggle("", isOn: $isLivestream)
                                .labelsHidden()
                            Text("Yes")
                        }
                        
                    }
                    
                    
                    TextField("Name",text:$name)
                        .accessibility(localIdentifier: .uploadNameTextField)

                    
                    TextField("Description",text:$description)
                        .accessibility(localIdentifier: .uploadDescriptionTextField)
                    
                    Picker(selection: $category, label: Text("Exercise Category")) {
                        ForEach(Exercise.Category.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    
                    if isLivestream{
                        Picker(selection: $duration, label: Text("Time Length")){
                            ForEach(1...40, id: \.self) {
                                Text("\($0) Min")
                            }
                        }
                        
                        Picker(selection: $peopleLimit, label: Text("People Limit")){
                            ForEach(1...50, id: \.self) {
                                Text("\($0) People")
                            }
                        }
                        
                        TextField("LiveStream Link",text:$contentLink)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .accessibility(localIdentifier: .uploadLinkTextfield)
                    }
                    if(name.count>25){Text("Name is too long").foregroundColor(.red)}
                }

                .sheet(isPresented: $isVideoPickerPresented) {
                    VideoPicker(videoURL: $videoURL, isLoading: $isVideoLoading, isPresented: $isVideoPickerPresented)
                }
            }
            Spacer()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image, isPresented: $isImagePickerPresented)
        }
    }
}

struct UploadSheetView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            UploadSheetView(publicProfile: PublicProfile.exampleProfile , isPresented: .constant(false))
        }
    }
    
}

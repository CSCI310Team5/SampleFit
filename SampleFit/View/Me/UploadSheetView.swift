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
                    }else{
                        newUpload.playbackType = Exercise.PlaybackType.recordedVideo
                        newUpload.image=image
                        newUpload.contentLink = videoURL!.absoluteString
                    }
                    publicProfile.createExercise(newExercise: newUpload, token: userData.token)
                    isPresented = false
                }) {
                    Text("Confirm").bold()
                }.disabled( name.isEmpty || name.count > 25 || description.isEmpty || (image == PublicProfile.exampleProfile.image && !isLivestream) || contentLink.isEmpty)
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
                        Text("Livestream")
                    }
                    
                    
                    if !isLivestream {
                        HStack {
                            Text("Preview Image")
                            Spacer()
                            Image(uiImage: image!)
                                .resizable().scaledToFit()
                        }.frame(height: 100)
                        
                        Button("Add Preview Image") {
                            isImagePickerPresented.toggle()
                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(image: $image, isPresented: $isImagePickerPresented)
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
                        .sheet(isPresented: $isVideoPickerPresented) {
                            VideoPicker(videoURL: $videoURL, isLoading: $isVideoLoading, isPresented: $isVideoPickerPresented)
                        }
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
                    
                    if isLivestream{
                        Picker(selection: $peopleLimit, label: Text("People Limit")){
                            ForEach(1...50, id: \.self) {
                                Text("\($0) People")
                            }
                        }
                        
                        TextField("LiveStream Link",text:$contentLink)
                    }
                    if(name.count>25){Text("Name is too long").foregroundColor(.red)}
                }
            }
            Spacer()
        }
        //        .onDisappear(
        //            perform: {
        //                print("hahahaha")
        //            }
        //        )
    }
}

struct UploadSheetView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            UploadSheetView(publicProfile: PublicProfile.exampleProfile , isPresented: .constant(false))
        }
    }
    
}

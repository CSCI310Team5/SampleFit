//
//  CommentView.swift
//  SampleFit
//
//  Created by apple on 4/24/21.
//

import SwiftUI
import Foundation
import Combine

class CommentHelper: ObservableObject{
    @Published var commentEmail:String = ""
}

struct CommentView: View {
    @ObservedObject var exercise: Exercise
    @ObservedObject var privateInformation: PrivateInformation
    
    @State private var comment:String=""
    
    @State private var showComment: Bool=false
    @State private var viewComment: Bool=false
    @State private var errorChecking: Bool=false
    @State private var page: Int = 0
    
    @ObservedObject var commentHelper: CommentHelper = CommentHelper()
    
    @State private var showUser=false
    

    var body: some View {
        VStack{
            
            Toggle("Show Comment Text Box", isOn: $showComment)
            
            if(showComment){
                
                TextField(
                    "Type In Your Comments",
                    text: $comment
                ).padding()
                .border(Color.black).frame(width: UIScreen.main.bounds.width-50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                HStack {
                    
                    if errorChecking{
                        Text("Cannot have empty comment").foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Button("Submit", action: {
                        if comment.count != 0{
                            errorChecking=false
                        exercise.addComment(email: privateInformation.email, token: privateInformation.authenticationToken, content: comment)
                            comment=""}
                        else{
                            errorChecking=true
                        }
                    })
                    .frame(width:70, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/).foregroundColor(.white)
                }.padding(.horizontal, 10)
            }
            
            if(viewComment){
                Button("Hide Comments", action: {viewComment.toggle()})
            }
            else{
                Button("View Comments", action: {
                    if(page==0){
                        exercise.getComment(page: 0)
                        page+=1
                    }
                    viewComment.toggle()
                    
                })
            }
            if(viewComment){
                VStack{
                    ForEach(exercise.comments.comments, id: \.id) {item in
                        
                        HStack{
                            Button("\(item.email)", action: {
                                commentHelper.commentEmail=item.email
                                showUser.toggle()
                                
                            })
                            Spacer()
                            Text(item.createTime).font(.caption2)
                        }
                        
                        Text("\(item.content)")
                        Divider()
                    }
                    
                    if page != exercise.comments.page_number {
                        Button("View More", action:{
                            exercise.getComment(page: page)
                            page+=1
                        })
                    }
                }.padding(.vertical, 10)
            }

        
        }.padding()
        .onDisappear{
            exercise.comments.comments.removeAll()
            page=0
        }
        .sheet(isPresented: $showUser, content: {
           
            let user = PublicProfile(identifier: commentHelper.commentEmail, fullName: nil)
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                user.getRemainingUserInfo(userEmail: user.identifier)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                user.getExerciseUploads(userEmail: user.identifier)
            }
           
            CommentHelperView(user: user, privateInformation: privateInformation)
            
        })
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(exercise: Exercise.exampleExercise , privateInformation: PrivateInformation.examplePrivateInformation)
    }
}

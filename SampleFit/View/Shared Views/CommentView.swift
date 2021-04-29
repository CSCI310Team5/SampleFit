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
    
    @State var showingAlert: Bool = false
    @State var index: IndexSet?
    
    @State var editComments: Bool = false
    
    func reset(){
        exercise.comments.comments.removeAll()
        page=0
        showComment=false
        viewComment=false
    }
    
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
            HStack{
                
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
                Spacer()
                
                Button("My Comments", action: {
                    exercise.getMyComment(email: privateInformation.email)
                    editComments.toggle()
                    reset()
                }
                )
                
            }.padding()
            
            if(viewComment){
                VStack{
                    ForEach(exercise.comments.comments, id: \.id) {item in
                        
                        HStack{
                            Button("\(item.email)", action: {
                                //                                commentHelper.commentEmail=item.email
                                //                                showUser.toggle()
                                
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
            reset()
        }
        
        .sheet(isPresented:$editComments , content: {
            VStack{
                HStack{
                    Button("Go Back", action: {editComments.toggle()})
                    Spacer()
                } .padding(.horizontal)
                .padding(.vertical, 20)
                
          
                Text("My Comments").bold().padding(.bottom,10)
                
                Divider()
                
                VStack(alignment: .center) {
                    if(exercise.userComments.count==0){
                        NoResults(title: "No Comments", description: "You don't have any comment for this video yet.")
                            .animation(.easeInOut)
                            .transition(.opacity)
                    }
                    List {
                        ForEach(exercise.userComments, id: \.id) { item in
                            CommentHelperView(item: item)
                                .alert(isPresented:$showingAlert) {
                                    Alert(
                                        title: Text("Are you sure you want to empty your history?"),
                                        message: Text("There is no undo"),
                                        primaryButton: .destructive(Text("Yes")) {
                                            exercise.removeComment(email: privateInformation.email, token: privateInformation.authenticationToken, at: index!)
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                        }
                        .onDelete {
                            index=$0
                            showingAlert.toggle()
                        }
                    }
                }
                
            }
            
        })
        
        //to be fixed
        //        .sheet(isPresented: $showUser, content: {
        //
        //            CommentHelperView(user: PublicProfile(identifier: commentHelper.commentEmail, fullName: nil), privateInformation: privateInformation)
        //
        //        })
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(exercise: Exercise.exampleExercise , privateInformation: PrivateInformation.examplePrivateInformation)
    }
}

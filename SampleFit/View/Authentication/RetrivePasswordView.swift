//
//  RetrivePasswordView.swift
//  SampleFit
//
//  Created by apple on 3/19/21.
//

import SwiftUI
import Foundation
import Combine

struct RetrivePasswordView: View {
    @EnvironmentObject var userData: UserData
    @Binding var retrievePassword: Bool
    @State private var email: String = ""
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {retrievePassword.toggle()}, label: {
                    Text("Back")
                })
                Spacer()
            }.padding()
            
            Text("Retrieve Your Password").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(.top, 30)
            
            
          
                VStack(alignment:.leading){
                    Text("Please Enter Your Email: ").padding()
                    HStack(spacing: 10){
                    Image(systemName: "person.circle")
                        .font(.title)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .font(.title3)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(minHeight: 44)
                    }.padding(.horizontal)
                }.padding(.vertical, 40)
            
            
            Button(action: {userData.retrievePassword(email: email)
            }, label: {
                Text("Retrieve Password")
            })
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 7.5)
                            .fill( Color.blue)
                    ).padding(.horizontal).padding(.bottom, 10)

            if(userData.changeDone==1){
                Text("Retrieve Password Request Completed, Your Temporary Password Is Sent Via Email").foregroundColor(.green)
            }
            if userData.changeDone == 0{
                Text("You will receive an email with temporary password").font(.callout).foregroundColor(.gray)
            }
            if userData.changeDone==3{
                Text("Either: Email does not exist, please reenter").foregroundColor(.red)
                Text("Or: You have just requested, please wait a bit").foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        
    }
    
}
    
    struct RetrivePasswordView_Previews: PreviewProvider {
        
        static var previews: some View {
            RetrivePasswordView(retrievePassword: .constant(true))
        }
    }

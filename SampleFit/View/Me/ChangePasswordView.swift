//
//  ChangePasswordView.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var userData: UserData
    @Binding var isPresented: Bool
    @State private var isDoneButtonEnabled = false
    // reusing CreateAccountInformation verification logic
    @ObservedObject private var draftInformation = CreateAccountInformation.resetPasswordInformation
    
    var body: some View {
        VStack(spacing: 50) {
            
            HStack {
                Button("Cancel", action: { isPresented = false })
                Spacer()
                Button(action: {
                    userData.changePassword(to: draftInformation.password)
                    isPresented = false
                }) {
                    Text("Confirm").bold()
                }
                .disabled(!draftInformation.allowsSignUp)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("Enter New Password")
                .font(Font.largeTitle.bold())
            
            VStack(spacing: 12) {
                // password
                CreateAccountPasswordTextField($draftInformation.password, inputStatus: draftInformation.passwordInputStatus)
                CreateAccountRepeatPasswordTextField($draftInformation.repeatPassword, inputStatus: draftInformation.repeatPasswordInputStatus)
            }
            .padding(.horizontal, 28)
            .padding(.top, 50)

            Spacer()
        }
        .onDisappear {
            draftInformation.password = ""
            draftInformation.repeatPassword = ""
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            ChangePasswordView(isPresented: .constant(false))
        }
    }
}

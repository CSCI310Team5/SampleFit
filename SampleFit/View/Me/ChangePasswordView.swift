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
    // reusing AuthenticationState verification logic
    @ObservedObject private var draftInformation = AuthenticationState.resetPasswordInformation
    
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
                .disabled(!draftInformation.allowsAuthentication)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("Enter New Password")
                .font(Font.largeTitle.bold())
            
            VStack(spacing: 12) {
                // password
                PasswordTextField(.password, text: $draftInformation.password, inputStatus: draftInformation.passwordInputStatus, colorType: \.signInColor)
                PasswordTextField(.verify, text: $draftInformation.repeatPassword, inputStatus: draftInformation.repeatPasswordInputStatus, colorType: \.signInColor)
            }
            .padding(.horizontal, 28)
            .padding(.top, 50)

            Spacer()
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            NavigationView { // force color scheme render
                ChangePasswordView(isPresented: .constant(false))
                    .navigationBarHidden(true)
            }
        }
    }
}

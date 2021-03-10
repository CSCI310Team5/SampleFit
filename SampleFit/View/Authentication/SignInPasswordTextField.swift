//
//  SignInPasswordTextField.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct SignInPasswordTextField: View {
    @ObservedObject var signInInformation: SignInInformation
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.circle")
                .font(Font.title)
                .foregroundColor(signInInformation.passwordInputStatus.signInColor)
            SecureField("Password", text: $signInInformation.password)
                .textContentType(.newPassword)
                .font(.title3)
                .frame(minHeight: 44)
        }
    }
}


struct SignInPasswordTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            SignInPasswordTextField(signInInformation: SignInInformation())
        }
    }
}

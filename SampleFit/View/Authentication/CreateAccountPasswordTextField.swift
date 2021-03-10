//
//  CreateAccountPasswordTextField.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct CreateAccountPasswordTextField: View {
    @Binding var password: String
    var inputStatus: InputStatus
    
    init(_ password: Binding<String>, inputStatus: InputStatus) {
        self._password = password
        self.inputStatus = inputStatus
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.circle")
                .font(Font.title)
                .foregroundColor(inputStatus.signUpColor)
            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .font(.title3)
                .frame(minHeight: 44)
        }
        .overlay(
            Group {
                if inputStatus == .validating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                if inputStatus == .invalid {
                    Text("Too Short")
                        .font(Font.callout.bold())
                        .foregroundColor(inputStatus.signUpColor)
                }
            }
            .padding(.trailing, 16)
        , alignment: .trailing)
    }
}

struct NewPasswordTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            CreateAccountPasswordTextField(.constant(""), inputStatus: InputStatus.invalid)
        }
    }
}

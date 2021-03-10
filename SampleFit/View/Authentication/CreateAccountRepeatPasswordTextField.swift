//
//  CreateAccountRepeatPasswordTextField.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct CreateAccountRepeatPasswordTextField: View {
    @Binding var repeatPassword: String
    var inputStatus: InputStatus
    
    init(_ repeatPassword: Binding<String>, inputStatus: InputStatus) {
        self._repeatPassword = repeatPassword
        self.inputStatus = inputStatus
    }
    
    var body: some View {
        // repeat password field
        HStack(spacing: 12) {
            Image(systemName: "lock.circle")
                .font(Font.title)
                .foregroundColor(inputStatus.signUpColor)
            SecureField("Repeat password", text: $repeatPassword)
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
                    Text("Does not match")
                        .font(Font.callout.bold())
                        .foregroundColor(inputStatus.signUpColor)
                }
            }
            .padding(.trailing, 16)
        , alignment: .trailing)
    }
}

struct CreateAccountRepeatPasswordTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            CreateAccountRepeatPasswordTextField(.constant(""), inputStatus: .valid)
        }
    }
}

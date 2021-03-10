//
//  PasswordTextField.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct PasswordTextField: View {
    enum Usage {
        case password
        case verify
    }
    var title: String
    var errorMessage: String
    @Binding var text: String
    var inputStatus: InputVerificationStatus
    var colorType: KeyPath<InputVerificationStatus, Color>
    
    init(_ style: Usage, text: Binding<String>, inputStatus: InputVerificationStatus, colorType: KeyPath<InputVerificationStatus, Color>) {
        if style == .password {
            self.title = "Password"
            self.errorMessage = "Too short"
        } else {
            title = "Repeat Password"
            self.errorMessage = "Does not match"
        }
        self._text = text
        self.inputStatus = inputStatus
        self.colorType = colorType
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.circle")
                .font(Font.title)
                .foregroundColor(inputStatus[keyPath: colorType])
            SecureField(title, text: $text)
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
                    Text(errorMessage)
                        .font(Font.callout.bold())
                        .foregroundColor(inputStatus[keyPath: colorType])
                }
            }
            .padding(.trailing, 16)
        , alignment: .trailing)
    }
}

struct NewPasswordTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            NavigationView { // force color scheme rendering
                PasswordTextField(.password, text: .constant(""), inputStatus: InputVerificationStatus.invalid, colorType: \.signUpColor)
            }
        }
    }
}

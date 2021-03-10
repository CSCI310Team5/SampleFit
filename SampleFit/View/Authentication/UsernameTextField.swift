//
//  CreateAccountUsernameTextField.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct UsernameTextField: View {
    @Binding var username: String
    var inputStatus: InputStatus
    var colorType: KeyPath<InputStatus, Color>
    
    init(_ username: Binding<String>, inputStatus: InputStatus, colorType: KeyPath<InputStatus, Color>) {
        self._username = username
        self.inputStatus = inputStatus
        self.colorType = colorType
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle")
                .font(.title)
                .foregroundColor(inputStatus.signUpColor)
            TextField("User name", text: $username)
                .textContentType(.username)
                .font(.title3)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(minHeight: 44)
        }
        .overlay(
            Group {
                if inputStatus == .validating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                if inputStatus == .invalid {
                    Text("Not Available")
                        .font(Font.callout.bold())
                        .foregroundColor(inputStatus[keyPath: colorType])
                }
            }
            .padding(.trailing, 16)
        , alignment: .trailing)
    }
}

struct NewUsernameTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            UsernameTextField(.constant(""), inputStatus: .notEntered, colorType: \.signInColor)
        }
    }
}

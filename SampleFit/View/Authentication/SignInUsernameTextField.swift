//
//  SignInUsernameTextField.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct SignInUsernameTextField: View {
    @ObservedObject var signInInformation: SignInInformation
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle")
                .font(.title)
                .foregroundColor(signInInformation.usernameInputStatus.signInColor)
            TextField("User name", text: $signInInformation.username)
                .textContentType(.username)
                .font(.title3)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(minHeight: 44)
        }
    }
}

struct SignInUsernameTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            SignInUsernameTextField(signInInformation: SignInInformation())
        }
    }
}

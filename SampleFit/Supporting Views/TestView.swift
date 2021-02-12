//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct TestView: View {
    @State private var username: String = ""
    @State private var isEditing = false

    var body: some View {
        
        TextField(
            "User name (email address)",
             text: $username
        ) { isEditing in
            self.isEditing = isEditing
        } onCommit: {
            // validate(name: username)
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .border(Color(UIColor.separator))
        .background(
            Text(username)
                .foregroundColor(isEditing ? .red : .blue)
            , alignment: .trailing
        )
        
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

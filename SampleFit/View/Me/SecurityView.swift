//
//  SecurityView.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import SwiftUI

struct SecurityView: View {
    @State private var isChangePasswordSheetPresented = false
    var body: some View {
        List {
            Button(action: { isChangePasswordSheetPresented = true }) {
                Text("Change Password")
            }
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(isPresented: $isChangePasswordSheetPresented) {
            ChangePasswordView(isPresented: $isChangePasswordSheetPresented)
        }
        
        
        .navigationBarTitle("Password & Security", displayMode: .inline)
    }
}

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            SecurityView()
        }
    }
}

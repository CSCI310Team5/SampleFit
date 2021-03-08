//
//  NotSetView.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct NotSetView: View {
    var isEditModeActive: Bool = false
    var body: some View {
        Text("Not Set")
            .foregroundColor(isEditModeActive ? .accentColor : Color(.placeholderText))
    }
}

struct NotSetView_Previews: PreviewProvider {
    static var previews: some View {
        NotSetView()
    }
}

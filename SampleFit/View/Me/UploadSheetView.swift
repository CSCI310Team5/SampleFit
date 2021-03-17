//
//  UploadSheetView.swift
//  SampleFit
//
//  Created by apple on 3/17/21.
//

import SwiftUI

struct UploadSheetView: View {
    
    @Binding var isPresented: Bool
 
    
    var body: some View {
        
        VStack {
            HStack {
                Button("Cancel", action: { isPresented = false })
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("Confirm").bold()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("Create Livestream Or Upload Video").bold()
            
            Spacer()
        }
       
    }
}

struct UploadSheetView_Previews: PreviewProvider {
    static var previews: some View {
        UploadSheetView(isPresented: .constant(false))
    }
}

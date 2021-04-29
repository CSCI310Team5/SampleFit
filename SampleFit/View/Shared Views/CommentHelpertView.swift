//
//  CommentListView.swift
//  SampleFit
//
//  Created by apple on 4/24/21.
//

import SwiftUI

struct CommentHelperView: View {
    var item: Comments.comment
    
    var body: some View {
        VStack(alignment:.leading){
            Text("\(item.content)")
        HStack{
            Spacer()
            Text(item.createTime).font(.caption2)
        }
        
       
        }
    }
}

struct CommentHelperView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}

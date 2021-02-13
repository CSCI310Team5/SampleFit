//
//  ExerciseCategoryItem.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct ExerciseCategoryItem: View {
    let allColors: [Color] = [.yellow, .blue, .green, .gray, .orange, .pink ,.purple ,.red]
    var body: some View {
        HStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 5)
                .fill(allColors.randomElement()!.opacity(Double.random(in: 0.5...1)))
                .frame(width: 200, height: 120)
            
            VStack(alignment: .leading) {
                Text("10min")
                    .font(.caption)
                Text("Dance with Abudala Awabel")
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
        
        
        
    }
}

struct CategoryItem_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCategoryItem()
    }
}

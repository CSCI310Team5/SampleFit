//
//  CategorySquareView.swift
//  SampleFit
//
//  Created by apple on 3/11/21.
//

import SwiftUI


struct CategorySquareView: View {
    var categoryName: String
    var body: some View {
        Text("\(categoryName)").background(Color.orange).foregroundColor(.white).font(.title3).frame(width: 170, height: 60).background(Color.orange)
    }
}

struct CategorySquareView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySquareView(categoryName: "Yoga")
    }
}

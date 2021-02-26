//
//  Color+Helpers.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/12/21.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    static var systemBackground: Color {
        return Color(UIColor.systemBackground)
    }
    static var systemFill: Color {
        return Color(UIColor.systemFill)
    }
    static var systemBlue: Color {
        return Color(UIColor.systemBlue)
    }
    static var tertiarySystemFill: Color {
        return Color(UIColor.tertiarySystemFill)
    }
    static var workoutLabelColor: Color {
        return Color(red: 241.0 / 255, green: 94.0 / 255, blue: 36.0 / 255)
    }
    static let allColors: [Color] = [.yellow, .blue, .green, .gray, .orange, .pink, .purple, .red]

}



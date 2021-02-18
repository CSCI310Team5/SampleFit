//
//  Exercise.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI

struct Exercise {
    var id: Int
    var name: String
    var category: Category
    var playbackType: PlaybackType
    fileprivate var previewImageIdentifier: String
    
    enum PlaybackType {
        case live
        case recordedVideo
    }
    
    enum Category: String {
        case hiit
        case pushup
        case cycling
        case squatting
        case other
    }
}

extension Exercise {
    var image: Image {
        ImageLoader.shared.image(withIdentifier: previewImageIdentifier)
    }
}

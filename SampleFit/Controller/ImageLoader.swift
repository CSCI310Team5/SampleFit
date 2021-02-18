//
//  ImageLoader.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI

struct ImageLoader {
    func image(withIdentifier identifier: String) -> Image {
        // FIXME: Should actually load an image either by querying the network or loading from local storage
        if _isImageIdentifierLocallyLodable(identifier) {
            return Image(identifier)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    private func _isImageIdentifierLocallyLodable(_ identifier: String) -> Bool {
        let localIdentifiers =
        [
            "cycling-1", "cycling-2", "cycling-3",
            "jogging-1", "jogging-2", "jogging-3",
            "hiit-1", "hiit-2", "hiit-3",
            "other-1", "other-2", "other-3",
        ]
        return localIdentifiers.contains(identifier)
    }
    
    static let shared = ImageLoader()
}

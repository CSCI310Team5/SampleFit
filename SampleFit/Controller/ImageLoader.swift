//
//  ImageLoader.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader {
    /// Returns an image with the specified identifier (either local or network URL), or returns a nil if image not found.
    func image(withIdentifier identifier: String) -> AnyPublisher<UIImage?, Never> {
        if _isImageIdentifierLocallyLodable(identifier) {
            return Just(UIImage(systemName: identifier))
                .eraseToAnyPublisher()
        } else {
            // FIXME: Use actual identifer to load image from network
            return NetworkQueryController.shared.loadImage(fromURL: URL(string:identifier)!)
        }
    }
    
    private func _isImageIdentifierLocallyLodable(_ identifier: String) -> Bool {
        let localIdentifiers =
        [
            "cycling-1", "cycling-2", "cycling-3",
            "jogging-1", "jogging-2", "jogging-3",
            "hiit-1", "hiit-2", "hiit-3",
            "pushup-1", "pushup-2", "pushup-3",
            "other-1", "other-2", "other-3",
        ]
        return localIdentifiers.contains(identifier)
    }
    
    static let shared = ImageLoader()
}

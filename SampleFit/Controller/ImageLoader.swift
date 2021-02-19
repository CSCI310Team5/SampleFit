//
//  ImageLoader.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import SwiftUI

struct ImageLoader {
    func image(withIdentifier identifier: String, completionHandler: @escaping (Result<Image, Error>) -> ()) {
        if _isImageIdentifierLocallyLodable(identifier) {
            completionHandler(.success(Image(identifier)))
        } else {
            // FIXME: Should loading over network
            NetworkQueryController.shared.loadImage(fromURL: URL(string: "http://apple.com")!) { (result) in
                completionHandler(result)
            }
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

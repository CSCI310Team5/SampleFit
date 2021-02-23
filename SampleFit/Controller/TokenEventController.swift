//
//  TokenEventController.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import Foundation
import UIKit
import Combine

enum TokenChangeEvent {
    case addToken(UISearchToken)
    case removeAllTokens
}

protocol TokenEventController {
    associatedtype Output
    var tokenWillChangePublisher: PassthroughSubject<TokenChangeEvent, Never> { get }
    func addToken(for: Output)
    func removeAllTokens()
}

class SearchCategoryTokenEventController: TokenEventController {
    var tokenWillChangePublisher = PassthroughSubject<TokenChangeEvent, Never>()

    func addToken(for category: Exercise.Category) {
        tokenWillChangePublisher.send(.addToken(category.searchToken))
    }
    
    func removeAllTokens() {
        tokenWillChangePublisher.send(.removeAllTokens)
    }
}

//
//  ViewModifer+Helpers.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/24/21.
//

import SwiftUI

struct LocalAccessibilityIdentifierModifier: ViewModifier {
    var identifier: AccessibilityIdentifiers
    
    init(identifier: AccessibilityIdentifiers) {
        self.identifier = identifier
    }
    
    func body(content: Content) -> some View {
        content.accessibility(identifier: identifier.rawValue)
    }
}

extension View {
    func accessibility(localIdentifier: AccessibilityIdentifiers) -> some View {
        self.modifier(LocalAccessibilityIdentifierModifier(identifier: localIdentifier))
    }
}

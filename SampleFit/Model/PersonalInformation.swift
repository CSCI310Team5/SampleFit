//
//  PersonalInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/18/21.
//

import Foundation
import SwiftUI

/// Stores user personalInformation.
class PersonalInformation: Identifiable {
    var identifier: String = ""
    var fullName: PersonNameComponents?
    var image: Image?
    
    init() {}
    init(identifier: String, fullName: PersonNameComponents?) {
        self.identifier = identifier
        self.fullName = fullName
    }
    
    // MARK: - Instance methods
    
    func shouldAppearOnSearchText(_ text: String) -> Bool {
        return self.identifier.lowercased().contains(text.lowercased()) ||
            self.fullName?.description.contains(text.lowercased()) ?? false
    }
    
    // MARK: - Convenience type properties
    
    static let examplePersonalInformation: [PersonalInformation] = [
        PersonalInformation(identifier: "Abudala Awabel", fullName: nil),
        PersonalInformation(identifier: "Tim Cook", fullName: nil),
        PersonalInformation(identifier: "Mark Redekopp", fullName: nil),
        PersonalInformation(identifier: "Andrew Goodney", fullName: nil),
        PersonalInformation(identifier: "Johnny Appleseed", fullName: nil),
        PersonalInformation(identifier: "Jane Doe", fullName: nil),
        PersonalInformation(identifier: "Carol Folt", fullName: nil),
        PersonalInformation(identifier: "Barack Obama", fullName: nil),
        PersonalInformation(identifier: "Mike Pence", fullName: nil),
        PersonalInformation(identifier: "Donald Trump", fullName: nil),
    ]
}

extension PersonalInformation: Equatable, Comparable {
    static func == (lhs: PersonalInformation, rhs: PersonalInformation) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static func < (lhs: PersonalInformation, rhs: PersonalInformation) -> Bool {
        return lhs.identifier < rhs.identifier
    }
    
    
}
